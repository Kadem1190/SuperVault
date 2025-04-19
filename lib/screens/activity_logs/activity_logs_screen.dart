import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/activity_log_model.dart';
import '../../models/user_model.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  String _selectedActivity = 'All Activities';
  String _selectedUser = 'All Users';
  String _searchQuery = '';
  
  final List<String> _activities = [
    'All Activities',
    'Create',
    'Read',
    'Update',
    'Delete',
  ];
  
  final List<String> _users = [
    'All Users',
    'Admin User',
    'John Smith',
    'Jane Doe',
    'Robert Johnson',
  ];
  
  // Mock activity log data
  final List<Map<String, dynamic>> _activityLogs = [
    {
      'id': '1',
      'userId': '1',
      'userName': 'Admin User',
      'userRole': UserRole.admin,
      'activityType': ActivityType.create,
      'entityType': 'Product',
      'entityId': '1',
      'entityName': 'Wireless Headphones',
      'description': 'Created new product: Wireless Headphones (WH-1001)',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'id': '2',
      'userId': '2',
      'userName': 'John Smith',
      'userRole': UserRole.staff,
      'activityType': ActivityType.update,
      'entityType': 'Inventory',
      'entityId': '1',
      'entityName': 'Wireless Headphones',
      'description': 'Updated inventory for Wireless Headphones: +50 units in Warehouse A',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'id': '3',
      'userId': '3',
      'userName': 'Jane Doe',
      'userRole': UserRole.staff,
      'activityType': ActivityType.read,
      'entityType': 'Warehouse',
      'entityId': '2',
      'entityName': 'Warehouse B',
      'description': 'Viewed warehouse details: Warehouse B',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': '4',
      'userId': '1',
      'userName': 'Admin User',
      'userRole': UserRole.admin,
      'activityType': ActivityType.delete,
      'entityType': 'Product',
      'entityId': '6',
      'entityName': 'Keyboard',
      'description': 'Deleted product: Keyboard (KB-6006)',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'id': '5',
      'userId': '4',
      'userName': 'Robert Johnson',
      'userRole': UserRole.staff,
      'activityType': ActivityType.update,
      'entityType': 'Transaction',
      'entityId': '3',
      'entityName': 'USB-C Cable',
      'description': 'Created transfer transaction: 20 units of USB-C Cable from Warehouse A to Warehouse C',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
    },
  ];
  
  List<Map<String, dynamic>> get _filteredLogs {
    return _activityLogs.where((log) {
      // Filter by activity type
      bool matchesActivity = _selectedActivity == 'All Activities';
      if (_selectedActivity == 'Create') {
        matchesActivity = log['activityType'] == ActivityType.create;
      } else if (_selectedActivity == 'Read') {
        matchesActivity = log['activityType'] == ActivityType.read;
      } else if (_selectedActivity == 'Update') {
        matchesActivity = log['activityType'] == ActivityType.update;
      } else if (_selectedActivity == 'Delete') {
        matchesActivity = log['activityType'] == ActivityType.delete;
      }
      
      // Filter by user
      final matchesUser = _selectedUser == 'All Users' || log['userName'] == _selectedUser;
      
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty || 
                           log['description'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           log['entityName'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesActivity && matchesUser && matchesSearch;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildActivityLogList(),
          ),
        ],
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
              hintText: 'Search activity logs',
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
                  value: _selectedActivity,
                  items: _activities,
                  onChanged: (value) {
                    setState(() {
                      _selectedActivity = value!;
                    });
                  },
                  hint: 'Activity Type',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  value: _selectedUser,
                  items: _users,
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value!;
                    });
                  },
                  hint: 'User',
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
  
  Widget _buildActivityLogList() {
    if (_filteredLogs.isEmpty) {
      return const Center(
        child: Text('No activity logs found'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildActivityLogItem(log);
      },
    );
  }
  
  Widget _buildActivityLogItem(Map<String, dynamic> log) {
    IconData activityIcon;
    Color activityColor;
    String activityText;
    
    switch (log['activityType']) {
      case ActivityType.create:
        activityIcon = Icons.add_circle_outline;
        activityColor = Colors.green;
        activityText = 'Create';
        break;
      case ActivityType.read:
        activityIcon = Icons.visibility_outlined;
        activityColor = Colors.blue;
        activityText = 'Read';
        break;
      case ActivityType.update:
        activityIcon = Icons.edit_outlined;
        activityColor = Colors.orange;
        activityText = 'Update';
        break;
      case ActivityType.delete:
        activityIcon = Icons.delete_outline;
        activityColor = Colors.red;
        activityText = 'Delete';
        break;
      default:
        activityIcon = Icons.help_outline;
        activityColor = Colors.grey;
        activityText = 'Unknown';
    }
    
    final timestamp = log['timestamp'] as DateTime;
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activityIcon,
                color: activityColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activityText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: activityColor,
                        ),
                      ),
                      Text(
                        '$formattedDate $formattedTime',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    log['description'],
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: log['userRole'] == UserRole.admin 
                              ? AppColors.primary.withOpacity(0.1) 
                              : AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log['userRole'] == UserRole.admin ? 'Admin' : 'Staff',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: log['userRole'] == UserRole.admin 
                                ? AppColors.primary 
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        log['userName'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
