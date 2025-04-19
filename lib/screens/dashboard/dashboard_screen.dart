import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../inventory/inventory_screen.dart';
import '../products/products_screen.dart';
import '../warehouses/warehouses_screen.dart';
import '../transactions/transactions_screen.dart';
import '../activity_logs/activity_logs_screen.dart';
import '../profile/profile_screen.dart';
import '../analytics/analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildDashboardHome(),
      const InventoryScreen(),
      const ProductsScreen(),
      const WarehousesScreen(),
      const TransactionsScreen(),
      if (widget.user.role == UserRole.admin) const ActivityLogsScreen(),
      if (widget.user.role == UserRole.admin) AnalyticsScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Inventory';
      case 2:
        return 'Products';
      case 3:
        return 'Warehouses';
      case 4:
        return 'Transactions';
      case 5:
        return widget.user.role == UserRole.admin ? 'Activity Logs' : 'Profile';
      case 6:
        return widget.user.role == UserRole.admin ? 'Analytics' : 'Profile';
      case 7:
        return 'Profile';
      default:
        return 'SuperVault';
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2_outlined,
            title: 'Inventory',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.category_outlined,
            title: 'Products',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.warehouse_outlined,
            title: 'Warehouses',
            index: 3,
          ),
          _buildDrawerItem(
            icon: Icons.sync_alt_outlined,
            title: 'Transactions',
            index: 4,
          ),
          if (widget.user.role == UserRole.admin)
            _buildDrawerItem(
              icon: Icons.history_outlined,
              title: 'Activity Logs',
              index: 5,
            ),
          if (widget.user.role == UserRole.admin)
            _buildDrawerItem(
              icon: Icons.analytics_outlined,
              title: 'Analytics',
              index: 6,
            ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'Profile',
            index: widget.user.role == UserRole.admin ? 7 : 5,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.user.name}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s an overview of your inventory',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          _buildStatCards(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildLowStockItems(),
          if (widget.user.role == UserRole.admin) ...[
            const SizedBox(height: 24),
            _buildStockMovementChartForDashboard(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Total Products',
          value: '124',
          icon: Icons.category_outlined,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Total Stock',
          value: '1,567',
          icon: Icons.inventory_2_outlined,
          color: AppColors.secondary,
        ),
        _buildStatCard(
          title: 'Warehouses',
          value: '3',
          icon: Icons.warehouse_outlined,
          color: AppColors.accent1,
        ),
        _buildStatCard(
          title: 'Low Stock Items',
          value: '12',
          icon: Icons.warning_amber_outlined,
          color: AppColors.accent2,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = widget.user.role == UserRole.admin ? 5 : 4;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              title: 'Stock Added',
              description: 'Added 50 units of Wireless Headphones',
              time: '10 minutes ago',
              icon: Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            _buildActivityItem(
              title: 'Stock Transferred',
              description: 'Transferred 20 units from Warehouse A to Warehouse B',
              time: '1 hour ago',
              icon: Icons.sync_alt_outlined,
              color: AppColors.secondary,
            ),
            _buildActivityItem(
              title: 'Stock Removed',
              description: 'Removed 15 units of Bluetooth Speakers',
              time: '3 hours ago',
              icon: Icons.remove_circle_outline,
              color: AppColors.accent2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low Stock Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildLowStockItem(
                  name: 'Wireless Headphones',
                  sku: 'WH-1001',
                  quantity: '5',
                  warehouse: 'Warehouse A',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockItem({
    required String name,
    required String sku,
    required String quantity,
    required String warehouse,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          color: Colors.grey,
        ),
      ),
      title: Text(name),
      subtitle: Text('SKU: $sku • $warehouse'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent2.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$quantity left',
          style: TextStyle(
            color: AppColors.accent2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStockMovementChartForDashboard() {
    // Mock data for stock movement
    final List<Map<String, dynamic>> stockMovementData = [
      {'day': 'Mon', 'stockIn': 45, 'stockOut': 30},
      {'day': 'Tue', 'stockIn': 38, 'stockOut': 42},
      {'day': 'Wed', 'stockIn': 55, 'stockOut': 35},
      {'day': 'Thu', 'stockIn': 25, 'stockOut': 28},
      {'day': 'Fri', 'stockIn': 60, 'stockOut': 48},
      {'day': 'Sat', 'stockIn': 35, 'stockOut': 20},
      {'day': 'Sun', 'stockIn': 15, 'stockOut': 12},
    ];

    return Card(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stock Movement (Last 7 Days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 6; // Navigate to Analytics screen
                    });
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Comparison of stock in vs stock out',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 70,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = stockMovementData[group.x.toInt()]['day'];
                        String value = rod.toY.round().toString();
                        String type = rodIndex == 0 ? 'Stock In' : 'Stock Out';
                        return BarTooltipItem(
                          '$type: $value\n$label',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(stockMovementData[value.toInt()]['day']),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString()),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: stockMovementData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['stockIn'].toDouble(),
                          color: AppColors.primary,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data['stockOut'].toDouble(),
                          color: AppColors.accent2,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItemForDashboard(AppColors.primary, 'Stock In'),
                const SizedBox(width: 24),
                _buildLegendItemForDashboard(AppColors.accent2, 'Stock Out'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItemForDashboard(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
