import 'package:flutter/material.dart';
import 'package:supervault/models/activity_log_model.dart';
import 'package:uuid/uuid.dart';
import '../../models/inventory_model.dart';
import '../../models/product_model.dart';
import '../../models/warehouse_model.dart';
import '../../models/user_model.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/warehouse_repository.dart';
import '../../repositories/activity_log_repository.dart';
import '../../utils/app_theme.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final User currentUser;
  final InventoryItem? inventoryItem; // Null for add, non-null for edit
  
  const AddEditInventoryScreen({
    super.key,
    required this.currentUser,
    this.inventoryItem,
  });

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedProductId;
  String? _selectedWarehouseId;
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  List<Product> _products = [];
  List<Warehouse> _warehouses = [];
  
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final ProductRepository _productRepository = ProductRepository();
  final WarehouseRepository _warehouseRepository = WarehouseRepository();
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
      
      // If editing, populate form fields
      if (widget.inventoryItem != null) {
        _selectedProductId = widget.inventoryItem!.productId;
        _selectedWarehouseId = widget.inventoryItem!.warehouseId;
        _quantityController.text = widget.inventoryItem!.quantity.toString();
        _locationController.text = widget.inventoryItem!.location;
      }
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
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _saveInventoryItem() async {
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
      
      setState(() {
        _isSaving = true;
      });
      
      try {
        final quantity = int.parse(_quantityController.text);
        
        if (widget.inventoryItem == null) {
          // Create new inventory item
          final newItem = InventoryItem(
            id: const Uuid().v4(),
            productId: _selectedProductId!,
            warehouseId: _selectedWarehouseId!,
            quantity: quantity,
            location: _locationController.text,
            status: _getStockStatus(quantity),
            lastUpdated: DateTime.now(),
          );
          
          await _inventoryRepository.createInventoryItem(newItem);
          
          // Log activity
          final product = _products.firstWhere((p) => p.id == _selectedProductId);
          final warehouse = _warehouses.firstWhere((w) => w.id == _selectedWarehouseId);
          
          await _activityLogRepository.createActivityLog(
            userId: widget.currentUser.id,
            userName: widget.currentUser.name,
            userRole: widget.currentUser.role,
            activityType: ActivityType.create,
            entityType: 'Inventory',
            entityId: newItem.id,
            description: 'Created inventory entry for ${product.name} in ${warehouse.name}',
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inventory item added successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          // Update existing inventory item
          final updatedItem = InventoryItem(
            id: widget.inventoryItem!.id,
            productId: _selectedProductId!,
            warehouseId: _selectedWarehouseId!,
            quantity: quantity,
            location: _locationController.text,
            status: _getStockStatus(quantity),
            lastUpdated: DateTime.now(),
          );
          
          await _inventoryRepository.updateInventoryItem(updatedItem);
          
          // Log activity
          final product = _products.firstWhere((p) => p.id == _selectedProductId);
          final warehouse = _warehouses.firstWhere((w) => w.id == _selectedWarehouseId);
          
          await _activityLogRepository.createActivityLog(
            userId: widget.currentUser.id,
            userName: widget.currentUser.name,
            userRole: widget.currentUser.role,
            activityType: ActivityType.update,
            entityType: 'Inventory',
            entityId: updatedItem.id,
            description: 'Updated inventory for ${product.name} in ${warehouse.name}',
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inventory item updated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        
        Navigator.pop(context, true); // Return success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving inventory item: $e'),
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
  
  StockStatus _getStockStatus(int quantity) {
    if (quantity <= 0) return StockStatus.outOfStock;
    if (quantity < 10) return StockStatus.low;
    return StockStatus.available;
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.inventoryItem != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Inventory Item' : 'Add Inventory Item'),
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
                      onChanged: isEditing ? null : (value) {
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
                    
                    // Warehouse dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Warehouse',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedWarehouseId,
                      items: _warehouses.map((warehouse) {
                        return DropdownMenuItem<String>(
                          value: warehouse.id,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: isEditing ? null : (value) {
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location field
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (e.g., Shelf A-12)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveInventoryItem,
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
                            : Text(isEditing ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
