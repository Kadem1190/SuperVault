import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/transaction_model.dart';
import '../../models/product_model.dart';
import '../../models/warehouse_model.dart';
import '../../models/user_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/warehouse_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/activity_log_repository.dart';
import '../../utils/app_theme.dart';
import '../../models/inventory_model.dart';
import '../../models/activity_log_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final User currentUser;
  
  const AddTransactionScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedProductId;
  String? _selectedWarehouseId;
  String? _selectedDestinationWarehouseId;
  TransactionType _selectedType = TransactionType.stockIn;
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showDestinationWarehouse = false;
  
  List<Product> _products = [];
  List<Warehouse> _warehouses = [];
  
  final TransactionRepository _transactionRepository = TransactionRepository();
  final ProductRepository _productRepository = ProductRepository();
  final WarehouseRepository _warehouseRepository = WarehouseRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load products and warehouses
      _products = await _productRepository.getAllProducts();
      _warehouses = await _warehouseRepository.getAllWarehouses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _onTransactionTypeChanged(TransactionType? type) {
    if (type != null) {
      setState(() {
        _selectedType = type;
        _showDestinationWarehouse = type == TransactionType.transfer;
        
        // Reset destination warehouse if not a transfer
        if (!_showDestinationWarehouse) {
          _selectedDestinationWarehouseId = null;
        }
      });
    }
  }
  
  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null || _selectedWarehouseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a product and warehouse'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_selectedType == TransactionType.transfer && _selectedDestinationWarehouseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a destination warehouse'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_selectedType == TransactionType.transfer && 
          _selectedWarehouseId == _selectedDestinationWarehouseId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Source and destination warehouses cannot be the same'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isSaving = true;
      });
      
      try {
        final quantity = int.parse(_quantityController.text);
        
        // Create transaction
        final transaction = Transaction(
          id: const Uuid().v4(),
          productId: _selectedProductId!,
          warehouseId: _selectedWarehouseId!,
          destinationWarehouseId: _selectedType == TransactionType.transfer ? 
            _selectedDestinationWarehouseId : null,
          userId: widget.currentUser.id,
          type: _selectedType,
          quantity: _selectedType == TransactionType.stockOut || _selectedType == TransactionType.adjustment ? 
            -quantity.abs() : quantity.abs(),
          notes: _notesController.text,
          timestamp: DateTime.now(),
        );
        
        await _transactionRepository.createTransaction(transaction);
        
        // Update inventory based on transaction type
        await _updateInventory(transaction);
        
        // Log activity
        final product = _products.firstWhere((p) => p.id == _selectedProductId);
        final warehouse = _warehouses.firstWhere((w) => w.id == _selectedWarehouseId);
        
        String activityDescription;
        switch (_selectedType) {
          case TransactionType.stockIn:
            activityDescription = 'Added ${quantity.abs()} units of ${product.name} to ${warehouse.name}';
            break;
          case TransactionType.stockOut:
            activityDescription = 'Removed ${quantity.abs()} units of ${product.name} from ${warehouse.name}';
            break;
          case TransactionType.transfer:
            final destinationWarehouse = _warehouses.firstWhere((w) => w.id == _selectedDestinationWarehouseId);
            activityDescription = 'Transferred ${quantity.abs()} units of ${product.name} from ${warehouse.name} to ${destinationWarehouse.name}';
            break;
          case TransactionType.adjustment:
            activityDescription = 'Adjusted ${product.name} inventory in ${warehouse.name} by ${quantity > 0 ? '+' : ''}$quantity units';
            break;
        }
        
        await _activityLogRepository.createActivityLog(
          userId: widget.currentUser.id,
          userName: widget.currentUser.name,
          userRole: widget.currentUser.role,
          activityType: ActivityType.create,
          entityType: 'Transaction',
          entityId: transaction.id,
          description: activityDescription,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        
        Navigator.pop(context, true); // Return success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  Future<void> _updateInventory(Transaction transaction) async {
    // Get current inventory for source warehouse
    var sourceInventory = await _inventoryRepository.getInventoryItem(
      transaction.productId, 
      transaction.warehouseId
    );
    
    // Update source warehouse inventory
    if (sourceInventory != null) {
      // Update existing inventory
      sourceInventory = await _inventoryRepository.updateInventoryItem(
        sourceInventory.copyWith(
          quantity: sourceInventory.quantity + transaction.quantity,
        ),
      );
    } else {
      // Create new inventory entry
      sourceInventory = await _inventoryRepository.createInventoryItem(
        InventoryItem(
          id: const Uuid().v4(),
          productId: transaction.productId,
          warehouseId: transaction.warehouseId,
          quantity: transaction.quantity,
          location: 'Default',
          status: transaction.quantity > 0 ? StockStatus.available : StockStatus.outOfStock,
          lastUpdated: DateTime.now(),
        ),
      );
    }
    
    // For transfers, update destination warehouse inventory
    if (transaction.type == TransactionType.transfer && 
        transaction.destinationWarehouseId != null) {
      // Get current inventory for destination warehouse
      var destInventory = await _inventoryRepository.getInventoryItem(
        transaction.productId, 
        transaction.destinationWarehouseId!
      );
      
      if (destInventory != null) {
        // Update existing inventory
        await _inventoryRepository.updateInventoryItem(
          destInventory.copyWith(
            quantity: destInventory.quantity + transaction.quantity.abs(),
          ),
        );
      } else {
        // Create new inventory entry
        await _inventoryRepository.createInventoryItem(
          InventoryItem(
            id: const Uuid().v4(),
            productId: transaction.productId,
            warehouseId: transaction.destinationWarehouseId!,
            quantity: transaction.quantity.abs(),
            location: 'Default',
            status: StockStatus.available,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Type
                    const Text(
                      'Transaction Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionTypeSelector(),
                    const SizedBox(height: 24),
                    
                    // Product dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProductId,
                      items: _products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.id,
                          child: Text('${product.name} (${product.sku})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Source Warehouse dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: _selectedType == TransactionType.transfer ? 
                          'Source Warehouse' : 'Warehouse',
                        border: const OutlineInputBorder(),
                      ),
                      value: _selectedWarehouseId,
                      items: _warehouses.map((warehouse) {
                        return DropdownMenuItem<String>(
                          value: warehouse.id,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWarehouseId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a warehouse';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Destination Warehouse dropdown (for transfers)
                    if (_showDestinationWarehouse) ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Destination Warehouse',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDestinationWarehouseId,
                        items: _warehouses
                          .where((w) => w.id != _selectedWarehouseId)
                          .map((warehouse) {
                            return DropdownMenuItem<String>(
                              value: warehouse.id,
                              child: Text(warehouse.name),
                            );
                          }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDestinationWarehouseId = value;
                          });
                        },
                        validator: (value) {
                          if (_showDestinationWarehouse && (value == null || value.isEmpty)) {
                            return 'Please select a destination warehouse';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Quantity field
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes field
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Transaction'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildTransactionTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTransactionTypeOption(
            type: TransactionType.stockIn,
            icon: Icons.add_circle_outline,
            color: Colors.green,
            label: 'Stock In',
          ),
        ),
        Expanded(
          child: _buildTransactionTypeOption(
            type: TransactionType.stockOut,
            icon: Icons.remove_circle_outline,
            color: Colors.red,
            label: 'Stock Out',
          ),
        ),
        Expanded(
          child: _buildTransactionTypeOption(
            type: TransactionType.transfer,
            icon: Icons.sync_alt_outlined,
            color: Colors.blue,
            label: 'Transfer',
          ),
        ),
        Expanded(
          child: _buildTransactionTypeOption(
            type: TransactionType.adjustment,
            icon: Icons.tune_outlined,
            color: Colors.orange,
            label: 'Adjustment',
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionTypeOption({
    required TransactionType type,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () => _onTransactionTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

extension InventoryItemExtension on InventoryItem {
  InventoryItem copyWith({
    String? id,
    String? productId,
    String? warehouseId,
    int? quantity,
    String? location,
    StockStatus? status,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
