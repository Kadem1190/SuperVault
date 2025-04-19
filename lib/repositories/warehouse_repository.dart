import '../models/warehouse_model.dart';
import '../services/database/database_service.dart';

class WarehouseRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Warehouse>> getAllWarehouses() async {
    final results = await _databaseService.query('SELECT * FROM warehouses');
    return results.map((json) => Warehouse.fromJson(json)).toList();
  }

  Future<Warehouse?> getWarehouseById(String id) async {
    final results = await _databaseService.query(
      'SELECT * FROM warehouses WHERE id = ?',
      [id]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Warehouse.fromJson(results.first);
  }

  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    await _databaseService.query(
      'INSERT INTO warehouses (id, name, address, contact_person, contact_phone, image_url) VALUES (?, ?, ?, ?, ?, ?)',
      [
        warehouse.id,
        warehouse.name,
        warehouse.address,
        warehouse.contactPerson,
        warehouse.contactPhone,
        warehouse.imageUrl,
      ]
    );
    
    return warehouse;
  }

  Future<Warehouse> updateWarehouse(Warehouse warehouse) async {
    await _databaseService.query(
      'UPDATE warehouses SET name = ?, address = ?, contact_person = ?, contact_phone = ?, image_url = ? WHERE id = ?',
      [
        warehouse.name,
        warehouse.address,
        warehouse.contactPerson,
        warehouse.contactPhone,
        warehouse.imageUrl,
        warehouse.id,
      ]
    );
    
    return warehouse;
  }

  Future<bool> deleteWarehouse(String id) async {
    final results = await _databaseService.query(
      'DELETE FROM warehouses WHERE id = ?',
      [id]
    );
    
    return results.isNotEmpty;
  }

  Future<Map<String, dynamic>> getWarehouseStats(String warehouseId) async {
    // Get total items in warehouse
    final itemCountResult = await _databaseService.query(
      'SELECT SUM(quantity) as total_items FROM inventory WHERE warehouse_id = ?',
      [warehouseId]
    );
    
    // Get unique product count in warehouse
    final productCountResult = await _databaseService.query(
      'SELECT COUNT(DISTINCT product_id) as total_products FROM inventory WHERE warehouse_id = ?',
      [warehouseId]
    );
    
    final totalItems = itemCountResult.isNotEmpty ? 
      (itemCountResult.first['total_items'] ?? 0) : 0;
    
    final totalProducts = productCountResult.isNotEmpty ? 
      (productCountResult.first['total_products'] ?? 0) : 0;
    
    return {
      'totalItems': totalItems,
      'totalProducts': totalProducts,
    };
  }
}
