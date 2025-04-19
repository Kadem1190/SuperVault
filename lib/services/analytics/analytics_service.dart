import 'package:flutter/foundation.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/warehouse_repository.dart';
import '../../repositories/product_repository.dart';

class AnalyticsService {
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final WarehouseRepository _warehouseRepository = WarehouseRepository();
  final ProductRepository _productRepository = ProductRepository();

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get all warehouses
      final warehouses = await _warehouseRepository.getAllWarehouses();
      
      // Get all products
      final products = await _productRepository.getAllProducts();
      
      // Get low stock items
      final lowStockItems = await _inventoryRepository.getLowStockItems(10);
      
      // Get total inventory count
      int totalStock = 0;
      final inventoryItems = await _inventoryRepository.getAllInventoryItems();
      for (final item in inventoryItems) {
        totalStock += item.quantity;
      }
      
      return {
        'totalProducts': products.length,
        'totalStock': totalStock,
        'warehouseCount': warehouses.length,
        'lowStockCount': lowStockItems.length,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'totalProducts': 0,
        'totalStock': 0,
        'warehouseCount': 0,
        'lowStockCount': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getStockMovementData(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      return await _transactionRepository.getStockMovementByDay(startDate, endDate);
    } catch (e) {
      debugPrint('Error getting stock movement data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWarehouseComparisonData() async {
    try {
      final warehouses = await _warehouseRepository.getAllWarehouses();
      final result = <Map<String, dynamic>>[];
      
      for (final warehouse in warehouses) {
        final stats = await _warehouseRepository.getWarehouseStats(warehouse.id);
        
        result.add({
          'warehouse': warehouse.name,
          'totalItems': stats['totalItems'],
          'capacity': 1000, // Mock capacity value
        });
      }
      
      return result;
    } catch (e) {
      debugPrint('Error getting warehouse comparison data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryDistributionData() async {
    try {
      final categories = await _productRepository.getAllCategories();
      final result = <Map<String, dynamic>>[];
      
      int totalProducts = 0;
      final categoryCountMap = <String, int>{};
      
      // Count products by category
      for (final category in categories) {
        final products = await _productRepository.getProductsByCategory(category);
        categoryCountMap[category] = products.length;
        totalProducts += products.length;
      }
      
      // Calculate percentages
      for (final entry in categoryCountMap.entries) {
        final percentage = (entry.value / totalProducts) * 100;
        
        result.add({
          'category': entry.key,
          'percentage': percentage.round(),
        });
      }
      
      return result;
    } catch (e) {
      debugPrint('Error getting category distribution data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrendsData(int months) async {
    try {
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - months, 1);
      
      final result = <Map<String, dynamic>>[];
      
      // Generate data for each month
      for (int i = 0; i < months; i++) {
        final month = DateTime(startDate.year, startDate.month + i, 1);
        final monthEnd = DateTime(month.year, month.month + 1, 0);
        
        final stats = await _transactionRepository.getTransactionStats(month, monthEnd);
        
        result.add({
          'month': _getMonthName(month.month),
          'stockIn': stats['stockIn'],
          'stockOut': stats['stockOut'],
        });
      }
      
      return result;
    } catch (e) {
      debugPrint('Error getting monthly trends data: $e');
      return [];
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
}
