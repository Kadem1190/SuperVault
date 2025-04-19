class Product {
  final String id;
  final String name;
  final String sku;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      description: json['description'],
      category: json['category'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
