import '../models/product_model.dart';
import '../services/database/database_service.dart';

class ProductRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Product>> getAllProducts() async {
    final results = await _databaseService.query('SELECT * FROM products');
    return results.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final results = await _databaseService.query(
      'SELECT * FROM products WHERE category = ?',
      [category]
    );
    
    return results.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final results = await _databaseService.query(
      'SELECT * FROM products WHERE id = ?',
      [id]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Product.fromJson(results.first);
  }

  Future<Product?> getProductBySku(String sku) async {
    final results = await _databaseService.query(
      'SELECT * FROM products WHERE sku = ?',
      [sku]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Product.fromJson(results.first);
  }

  Future<Product> createProduct(Product product) async {
    final now = DateTime.now();
    
    // Ensure product has created_at and updated_at timestamps
    final productWithTimestamps = Product(
      id: product.id,
      name: product.name,
      sku: product.sku,
      description: product.description,
      category: product.category,
      price: product.price,
      imageUrl: product.imageUrl,
      createdAt: now,
      updatedAt: now,
    );
    
    await _databaseService.query(
      'INSERT INTO products (id, name, sku, description, category, price, image_url, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        productWithTimestamps.id,
        productWithTimestamps.name,
        productWithTimestamps.sku,
        productWithTimestamps.description,
        productWithTimestamps.category,
        productWithTimestamps.price,
        productWithTimestamps.imageUrl,
        productWithTimestamps.createdAt.toIso8601String(),
        productWithTimestamps.updatedAt.toIso8601String(),
      ]
    );
    
    return productWithTimestamps;
  }

  Future<Product> updateProduct(Product product) async {
    final now = DateTime.now();
    
    // Update the updated_at timestamp
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      sku: product.sku,
      description: product.description,
      category: product.category,
      price: product.price,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
      updatedAt: now,
    );
    
    await _databaseService.query(
      'UPDATE products SET name = ?, sku = ?, description = ?, category = ?, price = ?, image_url = ?, updated_at = ? WHERE id = ?',
      [
        updatedProduct.name,
        updatedProduct.sku,
        updatedProduct.description,
        updatedProduct.category,
        updatedProduct.price,
        updatedProduct.imageUrl,
        updatedProduct.updatedAt.toIso8601String(),
        updatedProduct.id,
      ]
    );
    
    return updatedProduct;
  }

  Future<bool> deleteProduct(String id) async {
    final results = await _databaseService.query(
      'DELETE FROM products WHERE id = ?',
      [id]
    );
    
    return results.isNotEmpty;
  }

  Future<List<String>> getAllCategories() async {
    final results = await _databaseService.query('SELECT DISTINCT category FROM products');
    return results.map((json) => json['category'] as String).toList();
  }
}
