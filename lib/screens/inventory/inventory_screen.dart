import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/inventory_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedWarehouse = 'All Warehouses';
  String _selectedCategory = 'All Categories';
  String _searchQuery = '';

  final List<String> _warehouses = [
    'All Warehouses',
    'Warehouse A',
    'Warehouse B',
    'Warehouse C',
  ];

  final List<String> _categories = [
    'All Categories',
    'Electronics',
    'Clothing',
    'Home Goods',
    'Office Supplies',
  ];

  // Mock inventory data
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'id': '1',
      'name': 'Wireless Headphones',
      'sku': 'WH-1001',
      'category': 'Electronics',
      'warehouse': 'Warehouse A',
      'location': 'Shelf A-12',
      'quantity': 5,
      'status': StockStatus.low,
    },
    {
      'id': '2',
      'name': 'Bluetooth Speaker',
      'sku': 'BS-2002',
      'category': 'Electronics',
      'warehouse': 'Warehouse B',
      'location': 'Shelf B-05',
      'quantity': 0,
      'status': StockStatus.outOfStock,
    },
    {
      'id': '3',
      'name': 'USB-C Cable',
      'sku': 'UC-3003',
      'category': 'Electronics',
      'warehouse': 'Warehouse A',
      'location': 'Shelf A-03',
      'quantity': 120,
      'status': StockStatus.available,
    },
    {
      'id': '4',
      'name': 'Office Chair',
      'sku': 'OC-4004',
      'category': 'Office Supplies',
      'warehouse': 'Warehouse C',
      'location': 'Section C-02',
      'quantity': 8,
      'status': StockStatus.low,
    },
    {
      'id': '5',
      'name': 'Desk Lamp',
      'sku': 'DL-5005',
      'category': 'Home Goods',
      'warehouse': 'Warehouse B',
      'location': 'Shelf B-10',
      'quantity': 25,
      'status': StockStatus.available,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    return _inventoryItems.where((item) {
      final matchesWarehouse = _selectedWarehouse == 'All Warehouses' || 
                              item['warehouse'] == _selectedWarehouse;
      final matchesCategory = _selectedCategory == 'All Categories' || 
                             item['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
                           item['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           item['sku'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesWarehouse && matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildInventoryList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add/edit inventory item screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
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
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or SKU',
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _selectedWarehouse,
                  items: _warehouses,
                  onChanged: (value) {
                    setState(() {
                      _selectedWarehouse = value!;
                    });
                  },
                  hint: 'Warehouse',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  hint: 'Category',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(hint),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_filteredItems.isEmpty) {
      return const Center(
        child: Text('No inventory items found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildInventoryItem(item);
      },
    );
  }

  Widget _buildInventoryItem(Map<String, dynamic> item) {
    Color statusColor;
    String statusText;

    switch (item['status']) {
      case StockStatus.available:
        statusColor = Colors.green;
        statusText = 'In Stock';
        break;
      case StockStatus.low:
        statusColor = Colors.orange;
        statusText = 'Low Stock';
        break;
      case StockStatus.outOfStock:
        statusColor = Colors.red;
        statusText = 'Out of Stock';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${item['sku']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.warehouse_outlined,
                  label: item['warehouse'],
                ),
                _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  label: item['location'],
                ),
                _buildInfoItem(
                  icon: Icons.inventory_2_outlined,
                  label: '${item['quantity']} units',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // View details
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Update stock
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
