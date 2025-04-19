import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/transaction_model.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedType = 'All Types';
  String _selectedWarehouse = 'All Warehouses';
  String _searchQuery = '';
  
  final List<String> _types = [
    'All Types',
    'Stock In',
    'Stock Out',
    'Transfer',
    'Adjustment',
  ];
  
  final List<String> _warehouses = [
    'All Warehouses',
    'Warehouse A',
    'Warehouse B',
    'Warehouse C',
  ];
  
  // Mock transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': '1',
      'productName': 'Wireless Headphones',
      'productSku': 'WH-1001',
      'warehouseName': 'Warehouse A',
      'destinationWarehouseName': null,
      'userName': 'John Smith',
      'type': TransactionType.stockIn,
      'quantity': 50,
      'notes': 'Initial stock',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'id': '2',
      'productName': 'Bluetooth Speaker',
      'productSku': 'BS-2002',
      'warehouseName': 'Warehouse B',
      'destinationWarehouseName': null,
      'userName': 'Jane Doe',
      'type': TransactionType.stockOut,
      'quantity': 5,
      'notes': 'Customer order #12345',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '3',
      'productName': 'USB-C Cable',
      'productSku': 'UC-3003',
      'warehouseName': 'Warehouse A',
      'destinationWarehouseName': 'Warehouse C',
      'userName': 'Robert Johnson',
      'type': TransactionType.transfer,
      'quantity': 20,
      'notes': 'Rebalancing inventory',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '4',
      'productName': 'Office Chair',
      'productSku': 'OC-4004',
      'warehouseName': 'Warehouse C',
      'destinationWarehouseName': null,
      'userName': 'Admin User',
      'type': TransactionType.adjustment,
      'quantity': -2,
      'notes': 'Damaged items',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '5',
      'productName': 'Desk Lamp',
      'productSku': 'DL-5005',
      'warehouseName': 'Warehouse B',
      'destinationWarehouseName': null,
      'userName': 'John Smith',
      'type': TransactionType.stockIn,
      'quantity': 15,
      'notes': 'Restocking',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];
  
  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((transaction) {
      // Filter by type
      bool matchesType = _selectedType == 'All Types';
      if (_selectedType == 'Stock In') {
        matchesType = transaction['type'] == TransactionType.stockIn;
      } else if (_selectedType == 'Stock Out') {
        matchesType = transaction['type'] == TransactionType.stockOut;
      } else if (_selectedType == 'Transfer') {
        matchesType = transaction['type'] == TransactionType.transfer;
      } else if (_selectedType == 'Adjustment') {
        matchesType = transaction['type'] == TransactionType.adjustment;
      }
      
      // Filter by warehouse
      final matchesWarehouse = _selectedWarehouse == 'All Warehouses' || 
                              transaction['warehouseName'] == _selectedWarehouse ||
                              transaction['destinationWarehouseName'] == _selectedWarehouse;
      
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty || 
                           transaction['productName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           transaction['productSku'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           transaction['userName'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesType && matchesWarehouse && matchesSearch;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add transaction screen
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
              hintText: 'Search transactions',
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
                  value: _selectedType,
                  items: _types,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  hint: 'Transaction Type',
                ),
              ),
              const SizedBox(width: 16),
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
  
  Widget _buildTransactionList() {
    if (_filteredTransactions.isEmpty) {
      return const Center(
        child: Text('No transactions found'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }
  
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    IconData typeIcon;
    Color typeColor;
    String typeText;
    
    switch (transaction['type']) {
      case TransactionType.stockIn:
        typeIcon = Icons.add_circle_outline;
        typeColor = Colors.green;
        typeText = 'Stock In';
        break;
      case TransactionType.stockOut:
        typeIcon = Icons.remove_circle_outline;
        typeColor = Colors.red;
        typeText = 'Stock Out';
        break;
      case TransactionType.transfer:
        typeIcon = Icons.sync_alt_outlined;
        typeColor = Colors.blue;
        typeText = 'Transfer';
        break;
      case TransactionType.adjustment:
        typeIcon = Icons.tune_outlined;
        typeColor = Colors.orange;
        typeText = 'Adjustment';
        break;
      default:
        typeIcon = Icons.help_outline;
        typeColor = Colors.grey;
        typeText = 'Unknown';
    }
    
    final timestamp = transaction['timestamp'] as DateTime;
    final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction['productName']} (${transaction['productSku']})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warehouse',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(transaction['warehouseName']),
                    ],
                  ),
                ),
                if (transaction['type'] == TransactionType.transfer)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(transaction['destinationWarehouseName']),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction['quantity'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction['quantity'] > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(transaction['userName']),
                    ],
                  ),
                ),
              ],
            ),
            if (transaction['notes'] != null && transaction['notes'].isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(transaction['notes']),
            ],
          ],
        ),
      ),
    );
  }
}
