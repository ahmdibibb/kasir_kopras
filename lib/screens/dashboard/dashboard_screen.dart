import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../services/transaction_service.dart';
import '../../services/product_service.dart';
import '../../models/transaction.dart';
import '../../models/product.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionService _transactionService = Get.find<TransactionService>();
  final ProductService _productService = Get.find<ProductService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales Summary Cards
              _buildSalesSummary(),
              const SizedBox(height: AppTheme.spacingL),
              
              // Sales Chart
              _buildSalesChart(),
              const SizedBox(height: AppTheme.spacingL),
              
              // Low Stock Alert
              _buildLowStockAlert(),
              const SizedBox(height: AppTheme.spacingL),
              
              // Recent Transactions
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesSummary() {
    return FutureBuilder<Map<String, double>>(
      future: _getSalesSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Penjualan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Hari Ini',
                    amount: data['today'] ?? 0,
                    icon: Icons.today,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Minggu Ini',
                    amount: data['week'] ?? 0,
                    icon: Icons.calendar_view_week,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildSummaryCard(
              title: 'Bulan Ini',
              amount: data['month'] ?? 0,
              icon: Icons.calendar_month,
              color: AppTheme.successColor,
              isWide: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    bool isWide = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              Formatters.currency(amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik Penjualan (7 Hari Terakhir)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<double>>(
                future: _getWeeklySales(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(
                                  days[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: snapshot.data!
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return StreamBuilder<List<Product>>(
      stream: _productService.getLowStockProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final lowStockProducts = snapshot.data!;

        return Card(
          color: AppTheme.warningColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Stok Menipis',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.warningColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  '${lowStockProducts.length} produk memiliki stok rendah',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacingM),
                ...lowStockProducts.take(3).map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product.name),
                          Text(
                            'Stok: ${product.stock}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terbaru',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all transactions
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        StreamBuilder<List<Transaction>>(
          stream: _transactionService.getTodayTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Belum ada transaksi hari ini',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final transactions = snapshot.data!.take(5).toList();

            return Column(
              children: transactions.map((transaction) {
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Icon(
                        Icons.receipt,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(
                      Formatters.currency(transaction.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${transaction.totalItems} item • ${transaction.paymentMethod.label}',
                    ),
                    trailing: Text(
                      Formatters.time(transaction.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<Map<String, double>> _getSalesSummary() async {
    final now = DateTime.now();
    
    // Today
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todaySales = await _transactionService.calculateTotalSales(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    // This week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekSales = await _transactionService.calculateTotalSales(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: endOfDay,
    );

    // This month
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthSales = await _transactionService.calculateTotalSales(
      startDate: startOfMonth,
      endDate: endOfDay,
    );

    return {
      'today': todaySales,
      'week': weekSales,
      'month': monthSales,
    };
  }

  Future<List<double>> _getWeeklySales() async {
    final now = DateTime.now();
    final sales = <double>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final daySales = await _transactionService.calculateTotalSales(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      sales.add(daySales / 1000); // Divide by 1000 for better chart scaling
    }

    return sales;
  }
}
