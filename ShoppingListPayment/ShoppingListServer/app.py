from flask import Flask, jsonify, request
from collections import OrderedDict
from datetime import datetime
from werkzeug.utils import secure_filename
import os
import json
import re

app = Flask(__name__)

UPLOAD_FOLDER = 'static'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

USERS_FILE = 'data/users.json'

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def load_users():
    with open(USERS_FILE, 'r') as file:
        return json.load(file)

def load_categories():
    with open('data/categories.json', 'r') as file:
        return json.load(file)
    
def load_products():
    with open('data/products.json', 'r') as file:
        return json.load(file)

def load_orders():
    with open('data/orders.json', 'r') as file:
        return json.load(file)
    return []

def save_orders_to_file(updated_orders):
    json_string = json.dumps(updated_orders, indent=4)

    json_string = re.sub(
        r'(?<="products": )\[\s*([\s\S]*?)\s*\]',
        lambda match: '[' + ', '.join(match.group(1).split()) + ']',
        json_string
    )
    json_string = re.sub(
        r'(?<="quantities": )\[\s*([\s\S]*?)\s*\]',
        lambda match: '[' + ', '.join(match.group(1).split()) + ']',
        json_string
    )

    cleaned_json = re.sub(r',\s*,', ',', json_string)

    with open('data/orders.json', 'w') as file:
        file.write(cleaned_json)

def save_products_to_file(products):
    with open('data/products.json', 'w') as file:
        json.dump(products, file, indent=4)

@app.route('/categories', methods=['GET'])
def get_categories():
    categories = load_categories()
    return jsonify(categories)

@app.route('/products', methods=['GET'])
def get_products():
    products = load_products()
    return jsonify(products)

@app.route('/orders', methods=['GET'])
def get_orders():
    orders = load_orders()
    return jsonify(orders)

@app.route('/orders', methods=['POST'])
def save_order():
    new_order = request.get_json()
    orders = load_orders()

    new_order["id"] = max((order["id"] for order in orders), default=0) + 1

    products_with_quantities = sorted(
        zip(new_order.get("products", []), new_order.get("quantities", []))
    )
    sorted_products, sorted_quantities = zip(*products_with_quantities)

    rounded_total_price = round(new_order.get("totalPrice", 0.0), 2)

    new_order = OrderedDict({
        "id": new_order["id"],
        "date": new_order.get("date", ""),
        "totalPrice": rounded_total_price,
        "products": list(sorted_products),
        "quantities": list(sorted_quantities),
        "customerId": new_order.get("customerId", 1)
    })

    orders.append(new_order)
    save_orders_to_file(orders)

    return jsonify(new_order), 201

@app.route('/products', methods=['POST'])
def add_product():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in request'}), 400
    file = request.files['file']

    if not file or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type. Allowed: png, jpg, jpeg'}), 400

    filename = secure_filename(file.filename)
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

    product_data = request.form.to_dict()
    required_fields = ['name', 'descriptionText', 'price', 'categoryId']
    if not all(field in product_data for field in required_fields):
        missing_fields = [field for field in required_fields if field not in product_data]
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        product_data['price'] = float(product_data['price'])
        product_data['categoryId'] = int(product_data['categoryId'])
    except ValueError:
        return jsonify({'error': 'Invalid data type for price or categoryId'}), 400
    
    products = load_products()
    new_product_id = max((product['id'] for product in products), default=0) + 1
    new_product = OrderedDict({
        "id": new_product_id,
        "name": product_data['name'],
        "descriptionText": product_data['descriptionText'],
        "imageName": f"static/{filename}",
        "price": product_data['price'],
        "categoryId": product_data['categoryId']
    })
    products.append(new_product)
    save_products_to_file(products)

    return jsonify(new_product), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or 'username' not in data:
        return jsonify({'error': 'Missing username'}), 400

    username = data['username']
    oauth_id = data.get('oauth_id')
    token = data.get('token')

    users = load_users()

    if oauth_id:
        user = next((u for u in users if u['id'] == oauth_id), None)
        if user:
            if user['username'] == username:
                return jsonify({'message': 'Login successful', 'userId': user['id']}), 200
            else:
                return jsonify({'error': 'OAuth ID mismatch'}), 403
        else:
            new_user = OrderedDict({
                "id": oauth_id,
                "username": username,
                "password": token
            })
            users.append(new_user)
            with open(USERS_FILE, 'w') as file:
                json.dump(users, file, indent=4)
            return jsonify({'message': 'login successful', 'userId': oauth_id}), 201
    else:
        user = next((u for u in users if u['username'] == username), None)
        if user and user.get('password') == data.get('password'):
            return jsonify({'message': 'Login successful', 'userId': user['id']}), 200
        return jsonify({'error': 'Invalid username or password'}), 403

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Missing username or password'}), 400

    username = data['username']
    password = data['password']

    users = load_users()

    if any(u['username'] == username for u in users):
        return jsonify({'error': 'Username already exists'}), 409

    new_user_id = str(next(i for i in range(1, len(users) + 2) if str(i) not in {u['id'] for u in users}))
    new_user = OrderedDict({
        "id": new_user_id,
        "username": username,
        "password": password
    })
    users.append(new_user)

    with open(USERS_FILE, 'w') as file:
        json.dump(users, file, indent=4)

    return jsonify({'message': 'Registration successful', 'userId': new_user_id}), 201

@app.route('/pay', methods=['POST'])
def pay():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'Payment data is missing'}), 400
    
    required_fields = ['orderId', 'paymentDate', 'status', 'method', 'cardNumber', 'expiryDate', 'cvv', 'paymentId']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing field: {field}.'}), 400
    
    card_number = data['cardNumber'].replace(" ", "")
    expiry_date = data['expiryDate']
    cvv = data['cvv']

    try:
        if len(card_number) != 16:
            return jsonify({'status': 'failed', 'message': 'Invalid card number (must be 16 digits).'}), 400

        if len(cvv) != 3:
            return jsonify({'status': 'failed', 'message': 'Invalid CVV (must be 3 digits).'}), 400
        
        if len(expiry_date) != 5 or expiry_date[2] != '/':
            return jsonify({'status': 'failed', 'message': 'Invalid expiry date format (expected MM/YY).'}), 400

        expiry_month, expiry_year = map(int, expiry_date.split('/'))
        if expiry_month < 1 or expiry_month > 12:
            return jsonify({'status': 'failed', 'message': 'Invalid expiry month (must be between 01 and 12).'}), 400
        
        expiry_year += 2000 if expiry_year < 100 else 0
        expiry = datetime(expiry_year, expiry_month, 1)

        now = datetime.now()
        current_month_start = datetime(now.year, now.month, 1)
        if expiry < current_month_start:
            return jsonify({'status': 'failed', 'message': 'The card is expired.'}), 400
    except ValueError:
        return jsonify({'status': 'failed', 'message': 'Invalid expiry date format (expected MM/YY).'}), 400
    
    if data['method'] == "credit_card":
        payment_status = "completed"
    else:
        payment_status = "failed"

    orders = load_orders()

    for order in orders:
        if order['id'] == data['orderId']:
            order['paymentId'] = data['paymentId']
            break

    save_orders_to_file(orders)

    return jsonify({'status': payment_status, 'message': 'Payment processed successfully.'}), 200


if __name__ == "__main__":
    app.run(debug=True)
