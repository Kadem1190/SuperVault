import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/app_theme.dart';
import '../../../models/user_model.dart';

class AnalyticsScreen extends StatefulWidget {
  final User user;

  const AnalyticsScreen({super.key, required this.user});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedWarehouse = 'All Warehouses';
  String _selectedTimeRange = 'Last 7 Days';
  String _selectedCategory = 'All Categories';

  final List<String> _warehouses = [
    'All Warehouses',
    'Warehouse A',
    'Warehouse B',
    'Warehouse C',
  ];

  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last Year',
  ];

  final List<String> _categories = [
    'All Categories',
    'Electronics',
    'Clothing',
    'Home Goods',
    'Office Supplies',
  ];

  // Mock data for stock movement
  final List<Map<String, dynamic>> _stockMovementData = [
    {'day': 'Mon', 'stockIn': 45, 'stockOut': 30},
    {'day': 'Tue', 'stockIn': 38, 'stockOut': 42},
    {'day': 'Wed', 'stockIn': 55, 'stockOut': 35},
    {'day': 'Thu', 'stockIn': 25, 'stockOut': 28},
    {'day': 'Fri', 'stockIn': 60, 'stockOut': 48},
    {'day': 'Sat', 'stockIn': 35, 'stockOut': 20},
    {'day': 'Sun', 'stockIn': 15, 'stockOut': 12},
  ];

  // Mock data for warehouse comparison
  final List<Map<String, dynamic>> _warehouseComparisonData = [
    {'warehouse': 'Warehouse A', 'totalItems': 450, 'capacity': 600},
    {'warehouse': 'Warehouse B', 'totalItems': 320, 'capacity': 500},
    {'warehouse': 'Warehouse C', 'totalItems': 580, 'capacity': 700},
  ];

  // Mock data for category distribution
  final List<Map<String, dynamic>> _categoryDistributionData = [
    {'category': 'Electronics', 'percentage': 35},
    {'category': 'Clothing', 'percentage': 25},
    {'category': 'Home Goods', 'percentage': 20},
    {'category': 'Office Supplies', 'percentage': 15},
    {'category': 'Other', 'percentage': 5},
  ];

  // Mock data for monthly trends
  final List<Map<String, dynamic>> _monthlyTrendsData = [
    {'month': 'Jan', 'stockIn': 320, 'stockOut': 280},
    {'month': 'Feb', 'stockIn': 340, 'stockOut': 300},
    {'month': 'Mar', 'stockIn': 380, 'stockOut': 340},
    {'month': 'Apr', 'stockIn': 420, 'stockOut': 360},
    {'month': 'May', 'stockIn': 450, 'stockOut': 400},
    {'month': 'Jun', 'stockIn': 480, 'stockOut': 420},
  ];

  @override
  void initState() {
    super.initState();
    // Check if user is admin, if not, redirect
    if (widget.user.role != UserRole.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analytics is only available for admin users'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.role != UserRole.admin) {
      return const Scaffold(
        body: Center(
          child: Text('Analytics is only available for admin users'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildAnalyticsContent(),
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
                  value: _selectedTimeRange,
                  items: _timeRanges,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                    });
                  },
                  hint: 'Time Range',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            value: _selectedCategory,
            items: _categories,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
            hint: 'Category',
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

  Widget _buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildStockMovementChart(),
          const SizedBox(height: 24),
          _buildWarehouseComparisonChart(),
          const SizedBox(height: 24),
          _buildCategoryDistributionChart(),
          const SizedBox(height: 24),
          _buildMonthlyTrendsChart(),
        ],
      ),
    );
  }

  Widget _buildStockMovementChart() {
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
            Text(
              'Stock Movement (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 70,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = _stockMovementData[group.x.toInt()]['day'];
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
                            child: Text(_stockMovementData[value.toInt()]['day']),
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
                  barGroups: _stockMovementData.asMap().entries.map((entry) {
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
                _buildLegendItem(AppColors.primary, 'Stock In'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.accent2, 'Stock Out'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseComparisonChart() {
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
            Text(
              'Warehouse Capacity Utilization',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current inventory levels vs total capacity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 800,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = _warehouseComparisonData[group.x.toInt()]['warehouse'];
                        String value = rod.toY.round().toString();
                        String type = rodIndex == 0 ? 'Current' : 'Capacity';
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
                          final String label = _warehouseComparisonData[value.toInt()]['warehouse']
                              .toString()
                              .replaceAll('Warehouse ', '');
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(label),
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
                        reservedSize: 40,
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
                    horizontalInterval: 200,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _warehouseComparisonData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['totalItems'].toDouble(),
                          color: AppColors.secondary,
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data['capacity'].toDouble(),
                          color: Colors.grey.shade300,
                          width: 22,
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
                _buildLegendItem(AppColors.secondary, 'Current Inventory'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.grey.shade300, 'Total Capacity'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart() {
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
            Text(
              'Category Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Breakdown of inventory by category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _getCategorySections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(AppColors.primary, 'Electronics'),
                _buildLegendItem(AppColors.secondary, 'Clothing'),
                _buildLegendItem(AppColors.accent1, 'Home Goods'),
                _buildLegendItem(AppColors.accent2, 'Office Supplies'),
                _buildLegendItem(Colors.grey, 'Other'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategorySections() {
    final List<Color> colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent1,
      AppColors.accent2,
      Colors.grey,
    ];

    return List.generate(_categoryDistributionData.length, (i) {
      final data = _categoryDistributionData[i];
      final double percentage = data['percentage'].toDouble();
      final String category = data['category'];

      return PieChartSectionData(
        color: colors[i],
        value: percentage,
        title: '$percentage%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _percentage(percentage),
        badgePositionPercentageOffset: 1.2,
      );
    });
  }

  Widget? _percentage(double percentage) {
    return null;
  }

  Widget _buildMonthlyTrendsChart() {
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
            Text(
              'Monthly Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock movement over the last 6 months',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final data = _monthlyTrendsData[spot.x.toInt()];
                          final String month = data['month'];
                          final String type = spot.barIndex == 0 ? 'Stock In' : 'Stock Out';
                          return LineTooltipItem(
                            '$type: ${spot.y.toInt()}\n$month',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(_monthlyTrendsData[value.toInt()]['month']),
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
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: _monthlyTrendsData.length - 1.0,
                  minY: 0,
                  maxY: 500,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _monthlyTrendsData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['stockIn'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: _monthlyTrendsData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['stockOut'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppColors.accent2,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent2.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.primary, 'Stock In'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.accent2, 'Stock Out'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
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
