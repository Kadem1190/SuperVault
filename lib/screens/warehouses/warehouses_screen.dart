import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  String _searchQuery = '';

  // Mock warehouse data
  final List<Map<String, dynamic>> _warehouses = [
    {
      'id': '1',
      'name': 'Warehouse A',
      'address': '123 Main St, New York, NY 10001',
      'contactPerson': 'John Smith',
      'contactPhone': '(555) 123-4567',
      'totalItems': 450,
      'totalProducts': 35,
    },
    {
      'id': '2',
      'name': 'Warehouse B',
      'address': '456 Park Ave, Los Angeles, CA 90001',
      'contactPerson': 'Jane Doe',
      'contactPhone': '(555) 987-6543',
      'totalItems': 320,
      'totalProducts': 28,
    },
    {
      'id': '3',
      'name': 'Warehouse C',
      'address': '789 Oak St, Chicago, IL 60007',
      'contactPerson': 'Robert Johnson',
      'contactPhone': '(555) 456-7890',
      'totalItems': 580,
      'totalProducts': 42,
    },
  ];

  List<Map<String, dynamic>> get _filteredWarehouses {
    if (_searchQuery.isEmpty) {
      return _warehouses;
    }
    
    return _warehouses.where((warehouse) {
      return warehouse['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             warehouse['address'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             warehouse['contactPerson'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildWarehouseList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add/edit warehouse screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search warehouses',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildWarehouseList() {
    if (_filteredWarehouses.isEmpty) {
      return const Center(
        child: Text('No warehouses found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredWarehouses.length,
      itemBuilder: (context, index) {
        final warehouse = _filteredWarehouses[index];
        return _buildWarehouseCard(warehouse);
      },
    );
  }

  Widget _buildWarehouseCard(Map<String, dynamic> warehouse) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Warehouse Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warehouse_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warehouse['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        warehouse['address'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Warehouse Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Contact Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.person_outline,
                        label: 'Contact',
                        value: warehouse['contactPerson'],
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: warehouse['contactPhone'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Inventory Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'Total Items',
                        value: warehouse['totalItems'].toString(),
                        color: AppColors.secondary,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Products',
                        value: warehouse['totalProducts'].toString(),
                        color: AppColors.accent1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // View warehouse details
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Edit warehouse
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
