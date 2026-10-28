from flask import Flask, jsonify
import os

app = Flask(__name__)

products = [
    {"id": 1, "name": "Laptop", "price": 55000},
    {"id": 2, "name": "Mobile", "price": 25000},
    {"id": 3, "name": "Headphones", "price": 2500}
]


@app.route("/")
def home():
    return jsonify({
        "application": "Product Catalog API",
        "status": "running",
        "version": "1.0"
    })


@app.route("/products")
def get_products():
    return jsonify(products)


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.getenv("PORT", 5000))
    )