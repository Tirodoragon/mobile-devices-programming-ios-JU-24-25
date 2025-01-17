from flask import Flask, jsonify, request
from collections import OrderedDict
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

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

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

if __name__ == "__main__":
    app.run(debug=True)
