import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/warehouse_model.dart';
import '../../models/user_model.dart';
import '../../repositories/warehouse_repository.dart';
import '../../repositories/activity_log_repository.dart';
import '../../utils/app_theme.dart';
import '../../models/activity_log_model.dart'; // Use the correct ActivityType definition

class AddEditWarehouseScreen extends StatefulWidget {
  final User currentUser;
  final Warehouse? warehouse; // Null for add, non-null for edit

  const AddEditWarehouseScreen({
    super.key,
    required this.currentUser,
    this.warehouse,
  });

  @override
  State<AddEditWarehouseScreen> createState() => _AddEditWarehouseScreenState();
}

class _AddEditWarehouseScreenState extends State<AddEditWarehouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  final WarehouseRepository _warehouseRepository = WarehouseRepository();
  final ActivityLogRepository _activityLogRepository = ActivityLogRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // If editing, populate form fields
    if (widget.warehouse != null) {
      _nameController.text = widget.warehouse!.name;
      _addressController.text = widget.warehouse!.address;
      _contactPersonController.text = widget.warehouse!.contactPerson;
      _contactPhoneController.text = widget.warehouse!.contactPhone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveWarehouse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        if (widget.warehouse == null) {
          // Create new warehouse
          final newWarehouse = Warehouse(
            id: const Uuid().v4(),
            name: _nameController.text,
            address: _addressController.text,
            contactPerson: _contactPersonController.text,
            contactPhone: _contactPhoneController.text,
          );

          await _warehouseRepository.createWarehouse(newWarehouse);

          // Log activity
          final logSuccess = await _activityLogRepository.createActivityLog(
            userId: widget.currentUser.id,
            userName: widget.currentUser.name,
            userRole: widget.currentUser.role,
            activityType: ActivityType.create,
            entityType: 'Warehouse',
            entityId: newWarehouse.id,
            description: 'Created new warehouse: ${newWarehouse.name}',
          );

          if (logSuccess == false) {
            throw Exception('Failed to log activity');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Warehouse added successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          // Update existing warehouse
          final updatedWarehouse = Warehouse(
            id: widget.warehouse!.id,
            name: _nameController.text,
            address: _addressController.text,
            contactPerson: _contactPersonController.text,
            contactPhone: _contactPhoneController.text,
            imageUrl: widget.warehouse!.imageUrl,
          );

          await _warehouseRepository.updateWarehouse(updatedWarehouse);

          // Log activity
          final logSuccess = await _activityLogRepository.createActivityLog(
            userId: widget.currentUser.id,
            userName: widget.currentUser.name,
            userRole: widget.currentUser.role,
            activityType: ActivityType.update,
            entityType: 'Warehouse',
            entityId: updatedWarehouse.id,
            description: 'Updated warehouse: ${updatedWarehouse.name}',
          );

          if (logSuccess == false) {
            throw Exception('Failed to log activity');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Warehouse updated successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        Navigator.pop(context, true); // Return success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving warehouse: $e'),
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
    final isEditing = widget.warehouse != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Warehouse' : 'Add Warehouse'),
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
                        labelText: 'Warehouse Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a warehouse name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Person field
                    TextFormField(
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a contact person';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Phone field
                    TextFormField(
                      controller: _contactPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a contact phone';
                        }
                        if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveWarehouse,
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
