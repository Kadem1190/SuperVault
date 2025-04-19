enum TransactionType { stockIn, stockOut, transfer, adjustment }

class Transaction {
  final String id;
  final String productId;
  final String warehouseId;
  final String? destinationWarehouseId;
  final String userId;
  final TransactionType type;
  final int quantity;
  final String notes;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.productId,
    required this.warehouseId,
    this.destinationWarehouseId,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.notes,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    TransactionType getType(String typeStr) {
      switch (typeStr) {
        case 'stock_in':
          return TransactionType.stockIn;
        case 'stock_out':
          return TransactionType.stockOut;
        case 'transfer':
          return TransactionType.transfer;
        case 'adjustment':
          return TransactionType.adjustment;
        default:
          return TransactionType.adjustment;
      }
    }

    return Transaction(
      id: json['id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      destinationWarehouseId: json['destination_warehouse_id'],
      userId: json['user_id'],
      type: getType(json['type']),
      quantity: json['quantity'],
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    String getTypeString(TransactionType type) {
      switch (type) {
        case TransactionType.stockIn:
          return 'stock_in';
        case TransactionType.stockOut:
          return 'stock_out';
        case TransactionType.transfer:
          return 'transfer';
        case TransactionType.adjustment:
          return 'adjustment';
      }
    }

    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'destination_warehouse_id': destinationWarehouseId,
      'user_id': userId,
      'type': getTypeString(type),
      'quantity': quantity,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
