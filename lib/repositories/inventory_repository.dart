import '../models/inventory_model.dart';
import '../services/database/database_service.dart';

class InventoryRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<InventoryItem>> getAllInventoryItems() async {
    final results = await _databaseService.query('SELECT * FROM inventory');
    return results.map((json) => InventoryItem.fromJson(json)).toList();
  }

  Future<List<InventoryItem>> getInventoryByWarehouse(String warehouseId) async {
    final results = await _databaseService.query(
      'SELECT * FROM inventory WHERE warehouse_id = ?',
      [warehouseId]
    );
    
    return results.map((json) => InventoryItem.fromJson(json)).toList();
  }

  Future<List<InventoryItem>> getInventoryByProduct(String productId) async {
    final results = await _databaseService.query(
      'SELECT * FROM inventory WHERE product_id = ?',
      [productId]
    );
    
    return results.map((json) => InventoryItem.fromJson(json)).toList();
  }

  Future<InventoryItem?> getInventoryItem(String productId, String warehouseId) async {
    final results = await _databaseService.query(
      'SELECT * FROM inventory WHERE product_id = ? AND warehouse_id = ?',
      [productId, warehouseId]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return InventoryItem.fromJson(results.first);
  }

  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    final now = DateTime.now();
    
    // Create inventory item with current timestamp
    final itemWithTimestamp = InventoryItem(
      id: item.id,
      productId: item.productId,
      warehouseId: item.warehouseId,
      quantity: item.quantity,
      location: item.location,
      status: item.status,
      lastUpdated: now,
    );
    
    await _databaseService.query(
      'INSERT INTO inventory (id, product_id, warehouse_id, quantity, location, last_updated) VALUES (?, ?, ?, ?, ?, ?)',
      [
        itemWithTimestamp.id,
        itemWithTimestamp.productId,
        itemWithTimestamp.warehouseId,
        itemWithTimestamp.quantity,
        itemWithTimestamp.location,
        itemWithTimestamp.lastUpdated.toIso8601String(),
      ]
    );
    
    return itemWithTimestamp;
  }

  Future<InventoryItem> updateInventoryItem(InventoryItem item) async {
    final now = DateTime.now();
    
    // Update inventory item with current timestamp
    final updatedItem = InventoryItem(
      id: item.id,
      productId: item.productId,
      warehouseId: item.warehouseId,
      quantity: item.quantity,
      location: item.location,
      status: item.status,
      lastUpdated: now,
    );
    
    await _databaseService.query(
      'UPDATE inventory SET quantity = ?, location = ?, last_updated = ? WHERE id = ?',
      [
        updatedItem.quantity,
        updatedItem.location,
        updatedItem.lastUpdated.toIso8601String(),
        updatedItem.id,
      ]
    );
    
    return updatedItem;
  }

  Future<bool> deleteInventoryItem(String id) async {
    final results = await _databaseService.query(
      'DELETE FROM inventory WHERE id = ?',
      [id]
    );
    
    return results.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getLowStockItems(int threshold) async {
    // This query joins inventory with products to get product details
    final results = await _databaseService.query(
      '''
      SELECT i.*, p.name, p.sku, p.category, w.name as warehouse_name 
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      JOIN warehouses w ON i.warehouse_id = w.id
      WHERE i.quantity <= ?
      ''',
      [threshold]
    );
    
    return results;
  }
}
