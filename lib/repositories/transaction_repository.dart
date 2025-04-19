import '../models/transaction_model.dart';
import '../services/database/database_service.dart';

class TransactionRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Transaction>> getAllTransactions() async {
    final results = await _databaseService.query('SELECT * FROM transactions ORDER BY timestamp DESC');
    return results.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    String typeStr;
    switch (type) {
      case TransactionType.stockIn:
        typeStr = 'stock_in';
        break;
      case TransactionType.stockOut:
        typeStr = 'stock_out';
        break;
      case TransactionType.transfer:
        typeStr = 'transfer';
        break;
      case TransactionType.adjustment:
        typeStr = 'adjustment';
        break;
    }
    
    final results = await _databaseService.query(
      'SELECT * FROM transactions WHERE type = ? ORDER BY timestamp DESC',
      [typeStr]
    );
    
    return results.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getTransactionsByWarehouse(String warehouseId) async {
    final results = await _databaseService.query(
      'SELECT * FROM transactions WHERE warehouse_id = ? OR destination_warehouse_id = ? ORDER BY timestamp DESC',
      [warehouseId, warehouseId]
    );
    
    return results.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getTransactionsByProduct(String productId) async {
    final results = await _databaseService.query(
      'SELECT * FROM transactions WHERE product_id = ? ORDER BY timestamp DESC',
      [productId]
    );
    
    return results.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<Transaction?> getTransactionById(String id) async {
    final results = await _databaseService.query(
      'SELECT * FROM transactions WHERE id = ?',
      [id]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return Transaction.fromJson(results.first);
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    String typeStr;
    switch (transaction.type) {
      case TransactionType.stockIn:
        typeStr = 'stock_in';
        break;
      case TransactionType.stockOut:
        typeStr = 'stock_out';
        break;
      case TransactionType.transfer:
        typeStr = 'transfer';
        break;
      case TransactionType.adjustment:
        typeStr = 'adjustment';
        break;
    }
    
    await _databaseService.query(
      '''
      INSERT INTO transactions 
      (id, product_id, warehouse_id, destination_warehouse_id, user_id, type, quantity, notes, timestamp) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        transaction.id,
        transaction.productId,
        transaction.warehouseId,
        transaction.destinationWarehouseId,
        transaction.userId,
        typeStr,
        transaction.quantity,
        transaction.notes,
        transaction.timestamp.toIso8601String(),
      ]
    );
    
    return transaction;
  }

  Future<bool> deleteTransaction(String id) async {
    final results = await _databaseService.query(
      'DELETE FROM transactions WHERE id = ?',
      [id]
    );
    
    return results.isNotEmpty;
  }

  Future<Map<String, dynamic>> getTransactionStats(DateTime startDate, DateTime endDate) async {
    // Get stock in total
    final stockInResult = await _databaseService.query(
      '''
      SELECT SUM(quantity) as total 
      FROM transactions 
      WHERE type = 'stock_in' AND timestamp BETWEEN ? AND ?
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    // Get stock out total
    final stockOutResult = await _databaseService.query(
      '''
      SELECT SUM(quantity) as total 
      FROM transactions 
      WHERE type = 'stock_out' AND timestamp BETWEEN ? AND ?
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    // Get transfer total
    final transferResult = await _databaseService.query(
      '''
      SELECT SUM(quantity) as total 
      FROM transactions 
      WHERE type = 'transfer' AND timestamp BETWEEN ? AND ?
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    // Get adjustment total
    final adjustmentResult = await _databaseService.query(
      '''
      SELECT SUM(quantity) as total 
      FROM transactions 
      WHERE type = 'adjustment' AND timestamp BETWEEN ? AND ?
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    final stockInTotal = stockInResult.isNotEmpty ? 
      (stockInResult.first['total'] ?? 0) : 0;
    
    final stockOutTotal = stockOutResult.isNotEmpty ? 
      (stockOutResult.first['total'] ?? 0) : 0;
    
    final transferTotal = transferResult.isNotEmpty ? 
      (transferResult.first['total'] ?? 0) : 0;
    
    final adjustmentTotal = adjustmentResult.isNotEmpty ? 
      (adjustmentResult.first['total'] ?? 0) : 0;
    
    return {
      'stockIn': stockInTotal,
      'stockOut': stockOutTotal,
      'transfer': transferTotal,
      'adjustment': adjustmentTotal,
    };
  }

  Future<List<Map<String, dynamic>>> getStockMovementByDay(DateTime startDate, DateTime endDate) async {
    // This query gets daily stock movement data
    final results = await _databaseService.query(
      '''
      SELECT 
        DATE(timestamp) as day,
        SUM(CASE WHEN type = 'stock_in' THEN quantity ELSE 0 END) as stock_in,
        SUM(CASE WHEN type = 'stock_out' THEN quantity ELSE 0 END) as stock_out
      FROM transactions
      WHERE timestamp BETWEEN ? AND ?
      GROUP BY DATE(timestamp)
      ORDER BY day
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    return results;
  }
}
