// Product Model
class Product {
  final String name;
  final String sku;
  final double price;
  int quantity;

  Product({
    required this.name,
    required this.sku,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'price': price,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      sku: map['sku'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
