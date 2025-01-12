from flask import Flask, jsonify

app = Flask(__name__)

categories = [
    {
        "id": 1,
        "name": "Electronics",
        "descriptionText": "Devices and gadgets",
        "iconName": "static/electronics_icon.png"
    },
    {
        "id": 2,
        "name": "Home Appliances",
        "descriptionText": "Essential home devices",
        "iconName": "static/home_icon.png"
    }
]

products = [
    {
        "id": 1,
        "name": "Laptop",
        "descriptionText": "High-performance laptop with 16GB RAM",
        "imageName": "static/laptop_image.png",
        "price": 3499.99,
        "categoryId": 1
    },
    {
        "id": 2,
        "name": "Smartphone",
        "descriptionText": "OLED display smartphone with a 108 MP camera",
        "imageName": "static/smartphone_image.jpg",
        "price": 2999.99,
        "categoryId": 1,
    },
    {
        "id": 3,
        "name": "Refrigerator",
        "descriptionText": "Energy-efficient refrigerator with No Frost technology",
        "imageName": "static/fridge_image.jpg",
        "price": 2499.00,
        "categoryId": 2
    }
]

@app.route('/categories', methods=['GET'])
def get_categories():
    return jsonify(categories)

@app.route('/products', methods=['GET'])
def get_products():
    return jsonify(products)

@app.route('/categories/<int:categoryId>/products', methods=['GET'])
def get_products_by_category(categoryId):
    filtered_products = [p for p in products if p["categoryId"] == categoryId]
    return jsonify(filtered_products)

if __name__ == "__main__":
    app.run(debug=True)