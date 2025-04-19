import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/activity_log_repository.dart';
import '../../utils/app_theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final User currentUser;
  final Product? product; // Null for add, non-null for edit
  
  const AddEditProductScreen({
    super.key,
    required this.currentUser,
    this.product,
  });

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Electronics';
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home Goods',
    'Office Supplies',
  ];
  
  final ProductRepository _productRepository = ProductRepository();
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
      // Load categories
      final categories = await _productRepository.getAllCategories();
      if (categories.isNotEmpty) {
        _categories = categories;
      }
      
      // If editing, populate form fields
      if (widget.product != null) {
        _nameController.text = widget.product!.name;
        _skuController.text = widget.product!.sku;
        _descriptionController.text = widget.product!.description;
        _priceController.text = widget.product!.price.toString();
        _selectedCategory = widget.product!.category;
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
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final price = double.parse(_priceController.text);
        
        if (widget.product == null) {
          // Create new product
          final newProduct = Product(
            id: const Uuid().v4(),
            name: _nameController.text,
            sku: _skuController.text,
            description: _descriptionController.text,
            category: _selectedCategory,
            price: price,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _productRepository.createProduct(newProduct);
          
          // Log activity
          await _activityLogRepository.createActivityLog(
            userId: widget.currentUser.id,
            userName: widget.currentUser.name,
            userRole: widget.currentUser.role,
            activityType: ActivityType.create,
            entityType: 'Product',
            entityId: newProduct.id,
            description: 'Created new product: ${newProduct.name} (${newProduct.sku})',
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          // Update existing product
          final updatedProduct = Product(
            id: widget.product!.id,
            name: _nameController.text,
            sku: _skuController.text,
            description: _descriptionController.text,
            category: _selectedCategory,
            price: price,
            imageUrl: widget.product!.imageUrl,
            createdAt: widget.product!.createdAt,
            updatedAt: DateTime.now(),
          );
          
          await _productRepository.updateProduct(updatedProduct);
          
          // Log activity
          await _activityLogRepository.createActivityLog(
            userId: widget.currentUser.id,
            userName: widget.currentUser.name,
            userRole: widget.currentUser.role,
            activityType: ActivityType.update,
            entityType: 'Product',
            entityId: updatedProduct.id,
            description: 'Updated product: ${updatedProduct.name} (${updatedProduct.sku})',
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        
        Navigator.pop(context, true); // Return success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
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
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
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
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // SKU field
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a SKU';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Price field
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProduct,
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
