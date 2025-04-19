enum StockStatus { available, low, outOfStock }

class InventoryItem {
  final String id;
  final String productId;
  final String warehouseId;
  final int quantity;
  final String location;
  final StockStatus status;
  final DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.quantity,
    required this.location,
    required this.status,
    required this.lastUpdated,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    StockStatus getStatus(int quantity) {
      if (quantity <= 0) return StockStatus.outOfStock;
      if (quantity < 10) return StockStatus.low;
      return StockStatus.available;
    }

    return InventoryItem(
      id: json['id'],
      productId: json['product_id'],
      warehouseId: json['warehouse_id'],
      quantity: json['quantity'],
      location: json['location'],
      status: getStatus(json['quantity']),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'quantity': quantity,
      'location': location,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
