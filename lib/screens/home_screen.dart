import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'monthly_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _dayExpenses = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchExpensesForSelectedDate();
  }

  Future<void> _fetchExpensesForSelectedDate() async {
    final data = await DBHelper().getExpensesForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _dayExpenses = data;
      });
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _fetchExpensesForSelectedDate();
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _fetchExpensesForSelectedDate();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchExpensesForSelectedDate();
    }
  }

  double _calculateTotalExpenses() {
    double total = 0;
    for (var expense in _dayExpenses) {
      total += expense.amount;
    }
    return total;
  }

  Future<void> _deleteExpense(BuildContext context, int id) async {
    await DBHelper().deleteExpense(id);
    if (!mounted) return;
    _fetchExpensesForSelectedDate();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteExpense(context, expense.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    bool isToday =
        DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Navigator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Select Date',
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'View Monthly Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlyReportScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous Day',
                  onPressed: _goToPreviousDay,
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Text(
                    isToday ? 'Today ($formattedDate)' : formattedDate,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next Day',
                  onPressed: _goToNextDay,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Total: ₹${_calculateTotalExpenses().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _dayExpenses.isEmpty
                ? Center(
                    child: Text(
                      'No expenses added for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}.',
                    ),
                  )
                : ListView.builder(
                    itemCount: _dayExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _dayExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${expense.category} | ₹${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(
                                        selectedDate: expense.date,
                                        existingExpense: expense,
                                      ),
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    _fetchExpensesForSelectedDate();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Expense updated successfully!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(context, expense),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                selectedDate: _selectedDate,
              ),
            ),
          );
          if (result == true && mounted) {
            _fetchExpensesForSelectedDate();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expense added successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        tooltip: 'Add Expense for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
        child: const Icon(Icons.add),
      ),
    );
  }
}
