from flask import Flask, jsonify, request
from collections import OrderedDict
import json
import re

app = Flask(__name__)

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

if __name__ == "__main__":
    app.run(debug=True)
    