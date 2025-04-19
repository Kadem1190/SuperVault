import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/user_model.dart';

enum DatabaseMode {
  remote,
  local
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  MySqlConnection? _connection;
  DatabaseMode _mode = DatabaseMode.remote;
  bool _initialized = false;
  
  // Connection settings
  final String _host = 'your-clever-cloud-host.com'; // Replace with your Clever Cloud host
  final int _port = 3306;
  final String _user = 'your-username'; // Replace with your Clever Cloud username
  final String _password = 'your-password'; // Replace with your Clever Cloud password
  final String _db = 'supervault';

  DatabaseMode get mode => _mode;
  bool get isInitialized => _initialized;
  bool get isConnected => _connection != null;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _connectToRemoteDatabase();
      _mode = DatabaseMode.remote;
      debugPrint('Connected to remote database');
    } catch (e) {
      debugPrint('Failed to connect to remote database: $e');
      _mode = DatabaseMode.local;
      debugPrint('Falling back to local storage');
    }

    if (_mode == DatabaseMode.local) {
      await _initializeLocalStorage();
    }

    _initialized = true;
  }

  Future<void> _connectToRemoteDatabase() async {
    final settings = ConnectionSettings(
      host: _host,
      port: _port,
      user: _user,
      password: _password,
      db: _db,
    );

    _connection = await MySqlConnection.connect(settings);
    
    // Test connection
    final results = await _connection!.query('SELECT 1');
    if (results.isEmpty) {
      throw Exception('Database connection test failed');
    }
  }

  Future<void> _initializeLocalStorage() async {
    // Initialize local storage tables
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we need to create initial data
    if (!prefs.containsKey('db_initialized')) {
      await _createLocalTables();
      await _seedLocalData();
      await prefs.setBool('db_initialized', true);
    }
  }

  Future<void> _createLocalTables() async {
    final directory = await getApplicationDocumentsDirectory();
    
    // Create directory structure if it doesn't exist
    final dbDir = Directory('${directory.path}/supervault_db');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // Create empty files for each table
    final tables = [
      'users',
      'products',
      'categories',
      'warehouses',
      'inventory',
      'transactions',
      'activity_logs'
    ];

    for (final table in tables) {
      final file = File('${dbDir.path}/$table.json');
      if (!await file.exists()) {
        await file.writeAsString('[]');
      }
    }
  }

  Future<void> _seedLocalData() async {
    // Seed users
    final adminUser = User(
      id: '1',
      name: 'Admin User',
      email: 'admin@example.com',
      role: UserRole.admin,
    );

    final staffUser = User(
      id: '2',
      name: 'Staff User',
      email: 'staff@example.com',
      role: UserRole.staff,
    );

    await _writeLocalData('users', [adminUser.toJson(), staffUser.toJson()]);

    // Seed categories
    final categories = [
      {'id': '1', 'name': 'Electronics'},
      {'id': '2', 'name': 'Clothing'},
      {'id': '3', 'name': 'Home Goods'},
      {'id': '4', 'name': 'Office Supplies'},
    ];
    await _writeLocalData('categories', categories);

    // Seed warehouses
    final warehouses = [
      {
        'id': '1',
        'name': 'Warehouse A',
        'address': '123 Main St, New York, NY 10001',
        'contact_person': 'John Smith',
        'contact_phone': '(555) 123-4567',
      },
      {
        'id': '2',
        'name': 'Warehouse B',
        'address': '456 Park Ave, Los Angeles, CA 90001',
        'contact_person': 'Jane Doe',
        'contact_phone': '(555) 987-6543',
      },
      {
        'id': '3',
        'name': 'Warehouse C',
        'address': '789 Oak St, Chicago, IL 60007',
        'contact_person': 'Robert Johnson',
        'contact_phone': '(555) 456-7890',
      },
    ];
    await _writeLocalData('warehouses', warehouses);

    // Seed products
    final products = [
      {
        'id': '1',
        'name': 'Wireless Headphones',
        'sku': 'WH-1001',
        'description': 'High-quality wireless headphones with noise cancellation.',
        'category': 'Electronics',
        'price': 79.99,
        'image_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'name': 'Bluetooth Speaker',
        'sku': 'BS-2002',
        'description': 'Portable Bluetooth speaker with 10-hour battery life.',
        'category': 'Electronics',
        'price': 49.99,
        'image_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'name': 'USB-C Cable',
        'sku': 'UC-3003',
        'description': 'Durable USB-C charging cable, 2m length.',
        'category': 'Electronics',
        'price': 12.99,
        'image_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'name': 'Office Chair',
        'sku': 'OC-4004',
        'description': 'Ergonomic office chair with adjustable height and lumbar support.',
        'category': 'Office Supplies',
        'price': 149.99,
        'image_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'name': 'Desk Lamp',
        'sku': 'DL-5005',
        'description': 'LED desk lamp with adjustable brightness and color temperature.',
        'category': 'Home Goods',
        'price': 34.99,
        'image_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];
    await _writeLocalData('products', products);

    // Seed inventory
    final inventory = [
      {
        'id': '1',
        'product_id': '1',
        'warehouse_id': '1',
        'quantity': 5,
        'location': 'Shelf A-12',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'product_id': '2',
        'warehouse_id': '2',
        'quantity': 0,
        'location': 'Shelf B-05',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'product_id': '3',
        'warehouse_id': '1',
        'quantity': 120,
        'location': 'Shelf A-03',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'product_id': '4',
        'warehouse_id': '3',
        'quantity': 8,
        'location': 'Section C-02',
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'product_id': '5',
        'warehouse_id': '2',
        'quantity': 25,
        'location': 'Shelf B-10',
        'last_updated': DateTime.now().toIso8601String(),
      },
    ];
    await _writeLocalData('inventory', inventory);

    // Seed transactions
    final transactions = [
      {
        'id': '1',
        'product_id': '1',
        'warehouse_id': '1',
        'destination_warehouse_id': null,
        'user_id': '2',
        'type': 'stock_in',
        'quantity': 50,
        'notes': 'Initial stock',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      },
      {
        'id': '2',
        'product_id': '2',
        'warehouse_id': '2',
        'destination_warehouse_id': null,
        'user_id': '2',
        'type': 'stock_out',
        'quantity': 5,
        'notes': 'Customer order #12345',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': '3',
        'product_id': '3',
        'warehouse_id': '1',
        'destination_warehouse_id': '3',
        'user_id': '2',
        'type': 'transfer',
        'quantity': 20,
        'notes': 'Rebalancing inventory',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': '4',
        'product_id': '4',
        'warehouse_id': '3',
        'destination_warehouse_id': null,
        'user_id': '1',
        'type': 'adjustment',
        'quantity': -2,
        'notes': 'Damaged items',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': '5',
        'product_id': '5',
        'warehouse_id': '2',
        'destination_warehouse_id': null,
        'user_id': '2',
        'type': 'stock_in',
        'quantity': 15,
        'notes': 'Restocking',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
    await _writeLocalData('transactions', transactions);

    // Seed activity logs
    final activityLogs = [
      {
        'id': '1',
        'user_id': '1',
        'user_name': 'Admin User',
        'user_role': 'admin',
        'activity_type': 'create',
        'entity_type': 'Product',
        'entity_id': '1',
        'description': 'Created new product: Wireless Headphones (WH-1001)',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      },
      {
        'id': '2',
        'user_id': '2',
        'user_name': 'Staff User',
        'user_role': 'staff',
        'activity_type': 'update',
        'entity_type': 'Inventory',
        'entity_id': '1',
        'description': 'Updated inventory for Wireless Headphones: +50 units in Warehouse A',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      },
      {
        'id': '3',
        'user_id': '2',
        'user_name': 'Staff User',
        'user_role': 'staff',
        'activity_type': 'read',
        'entity_type': 'Warehouse',
        'entity_id': '2',
        'description': 'Viewed warehouse details: Warehouse B',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'id': '4',
        'user_id': '1',
        'user_name': 'Admin User',
        'user_role': 'admin',
        'activity_type': 'delete',
        'entity_type': 'Product',
        'entity_id': '6',
        'description': 'Deleted product: Keyboard (KB-6006)',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'id': '5',
        'user_id': '2',
        'user_name': 'Staff User',
        'user_role': 'staff',
        'activity_type': 'update',
        'entity_type': 'Transaction',
        'entity_id': '3',
        'description': 'Created transfer transaction: 20 units of USB-C Cable from Warehouse A to Warehouse C',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];
    await _writeLocalData('activity_logs', activityLogs);
  }

  Future<void> _writeLocalData(String table, List<dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/supervault_db/$table.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? params]) async {
    if (_mode == DatabaseMode.remote && _connection != null) {
      final results = await _connection!.query(sql, params);
      return results.map((r) => r.fields).toList();
    } else {
      // Parse the SQL query to determine what to do with local storage
      return await _handleLocalQuery(sql, params);
    }
  }

  Future<List<Map<String, dynamic>>> _handleLocalQuery(String sql, [List<dynamic>? params]) async {
    // This is a simplified SQL parser for basic CRUD operations
    sql = sql.toLowerCase();
    
    if (sql.contains('select')) {
      return await _handleLocalSelect(sql, params);
    } else if (sql.contains('insert')) {
      return await _handleLocalInsert(sql, params);
    } else if (sql.contains('update')) {
      return await _handleLocalUpdate(sql, params);
    } else if (sql.contains('delete')) {
      return await _handleLocalDelete(sql, params);
    }
    
    return [];
  }

  Future<List<Map<String, dynamic>>> _handleLocalSelect(String sql, [List<dynamic>? params]) async {
    // Extract table name from SQL
    final tableRegex = RegExp(r'from\s+(\w+)');
    final tableMatch = tableRegex.firstMatch(sql);
    
    if (tableMatch == null) return [];
    
    final tableName = tableMatch.group(1);
    if (tableName == null) return [];
    
    // Read data from local file
    final data = await _readLocalData(tableName);
    
    // Handle WHERE clause if present
    if (sql.contains('where') && params != null && params.isNotEmpty) {
      final whereRegex = RegExp(r'where\s+(\w+)\s*=\s*\?');
      final whereMatch = whereRegex.firstMatch(sql);
      
      if (whereMatch != null) {
        final fieldName = whereMatch.group(1);
        if (fieldName != null) {
          return data.where((item) => item[fieldName].toString() == params[0].toString()).toList();
        }
      }
    }
    
    return data;
  }

  Future<List<Map<String, dynamic>>> _handleLocalInsert(String sql, [List<dynamic>? params]) async {
    // Extract table name from SQL
    final tableRegex = RegExp(r'into\s+(\w+)');
    final tableMatch = tableRegex.firstMatch(sql);
    
    if (tableMatch == null || params == null) return [];
    
    final tableName = tableMatch.group(1);
    if (tableName == null) return [];
    
    // Read existing data
    final data = await _readLocalData(tableName);
    
    // Extract field names from SQL
    final fieldsRegex = RegExp(r'$$([^)]+)$$');
    final fieldsMatch = fieldsRegex.firstMatch(sql);
    
    if (fieldsMatch == null) return [];
    
    final fieldsStr = fieldsMatch.group(1);
    if (fieldsStr == null) return [];
    
    final fields = fieldsStr.split(',').map((f) => f.trim()).toList();
    
    // Create new record
    final newRecord = <String, dynamic>{};
    for (int i = 0; i < fields.length; i++) {
      if (i < params.length) {
        newRecord[fields[i]] = params[i];
      }
    }
    
    // Add new record
    data.add(newRecord);
    
    // Write updated data
    await _writeLocalData(tableName, data);
    
    return [newRecord];
  }

  Future<List<Map<String, dynamic>>> _handleLocalUpdate(String sql, [List<dynamic>? params]) async {
    // Extract table name from SQL
    final tableRegex = RegExp(r'update\s+(\w+)');
    final tableMatch = tableRegex.firstMatch(sql);
    
    if (tableMatch == null || params == null) return [];
    
    final tableName = tableMatch.group(1);
    if (tableName == null) return [];
    
    // Read existing data
    final data = await _readLocalData(tableName);
    
    // Extract field names from SQL
    final setRegex = RegExp(r'set\s+([^where]+)');
    final setMatch = setRegex.firstMatch(sql);
    
    if (setMatch == null) return [];
    
    final setStr = setMatch.group(1);
    if (setStr == null) return [];
    
    final sets = setStr.split(',').map((s) {
      final parts = s.split('=');
      return {
        'field': parts[0].trim(),
        'placeholder': parts[1].trim() == '?' ? true : false,
      };
    }).toList();
    
    // Handle WHERE clause
    final whereRegex = RegExp(r'where\s+(\w+)\s*=\s*\?');
    final whereMatch = whereRegex.firstMatch(sql);
    
    if (whereMatch == null) return [];
    
    final whereField = whereMatch.group(1);
    if (whereField == null) return [];
    
    final whereValue = params.last?.toString() ?? ''; // Convert to string with null check
    
    // Update records
    final updatedRecords = <Map<String, dynamic>>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i][whereField]?.toString() == whereValue) {
        int paramIndex = 0;
        for (final set in sets) {
          if (set['placeholder'] == true) {
          final value = params[paramIndex++];
         // Make sure that 'field' is treated as a String for the map access
         final fieldName = set['field'] as String;
  
         // Then assign the value, preserving its type rather than forcing to string
         data[i][fieldName] = value;
  
  // If you specifically need it as a string:
  // data[i][fieldName] = value?.toString() ?? '';
}
        }
        updatedRecords.add(data[i]);
      }
    }
    
    // Write updated data
    await _writeLocalData(tableName, data);
    
    return updatedRecords;
  }

  Future<List<Map<String, dynamic>>> _handleLocalDelete(String sql, [List<dynamic>? params]) async {
    // Extract table name from SQL
    final tableRegex = RegExp(r'from\s+(\w+)');
    final tableMatch = tableRegex.firstMatch(sql);
    
    if (tableMatch == null || params == null) return [];
    
    final tableName = tableMatch.group(1);
    if (tableName == null) return [];
    
    // Read existing data
    final data = await _readLocalData(tableName);
    
    // Handle WHERE clause
    final whereRegex = RegExp(r'where\s+(\w+)\s*=\s*\?');
    final whereMatch = whereRegex.firstMatch(sql);
    
    if (whereMatch == null) return [];
    
    final whereField = whereMatch.group(1);
    if (whereField == null) return [];
    
    final whereValue = params[0];
    
    // Find records to delete
    final deletedRecords = data.where((item) => 
      item[whereField].toString() == whereValue.toString()).toList();
    
    // Remove records
    data.removeWhere((item) => 
      item[whereField].toString() == whereValue.toString());
    
    // Write updated data
    await _writeLocalData(tableName, data);
    
    return deletedRecords;
  }

  Future<List<Map<String, dynamic>>> _readLocalData(String table) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/supervault_db/$table.json');
    
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
