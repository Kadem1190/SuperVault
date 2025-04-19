import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All Categories';
  String _searchQuery = '';

  final List<String> _categories = [
    'All Categories',
    'Electronics',
    'Clothing',
    'Home Goods',
    'Office Supplies',
  ];

  // Mock product data
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Wireless Headphones',
      'sku': 'WH-1001',
      'category': 'Electronics',
      'price': 79.99,
      'description': 'High-quality wireless headphones with noise cancellation.',
      'imageUrl': null,
    },
    {
      'id': '2',
      'name': 'Bluetooth Speaker',
      'sku': 'BS-2002',
      'category': 'Electronics',
      'price': 49.99,
      'description': 'Portable Bluetooth speaker with 10-hour battery life.',
      'imageUrl': null,
    },
    {
      'id': '3',
      'name': 'USB-C Cable',
      'sku': 'UC-3003',
      'category': 'Electronics',
      'price': 12.99,
      'description': 'Durable USB-C charging cable, 2m length.',
      'imageUrl': null,
    },
    {
      'id': '4',
      'name': 'Office Chair',
      'sku': 'OC-4004',
      'category': 'Office Supplies',
      'price': 149.99,
      'description': 'Ergonomic office chair with adjustable height and lumbar support.',
      'imageUrl': null,
    },
    {
      'id': '5',
      'name': 'Desk Lamp',
      'sku': 'DL-5005',
      'category': 'Home Goods',
      'price': 34.99,
      'description': 'LED desk lamp with adjustable brightness and color temperature.',
      'imageUrl': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All Categories' || 
                             product['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
                           product['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           product['sku'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add/edit product screen
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Category'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${product['sku']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () {
                          // Edit product
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        onPressed: () {
                          // View product details
                        },
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
