import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/db_helper.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<String, double> categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    final dbHelper = DBHelper();
    final allExpenses = await dbHelper.getExpenses();
    final Map<String, double> totals = {};

    for (var expense in allExpenses) {
      if (expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month) {
        totals.update(expense.category, (value) => value + expense.amount,
            ifAbsent: () => expense.amount);
      }
    }

    setState(() {
      categoryTotals = totals;
    });
  }

  Future<void> _pickMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select a month',
      fieldHintText: 'Month/Year',
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
      _fetchMonthlyData();
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var amount in categoryTotals.values) {
      total += amount;
    }
    return total;
  }

  List<PieChartSectionData> _generatePieChartData() {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
    ];

    int colorIndex = 0;

    return categoryTotals.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n₹${entry.value.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickMonth(context),
            tooltip: 'Select Month',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categoryTotals.isEmpty
            ? Center(child: Text('No expenses for $monthYear.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Expenses for $monthYear',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _generatePieChartData(),
                        centerSpaceRadius: 50,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(enabled: true),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
