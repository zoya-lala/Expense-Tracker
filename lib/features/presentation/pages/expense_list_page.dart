import 'package:expense_tracker/services/notify.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/expense_provider.dart';
import 'add_edit_expense_page.dart';

class ExpenseListPage extends StatefulWidget {
  final NotificationService? notificationService;

  const ExpenseListPage({this.notificationService, Key? key}) : super(key: key);

  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  DateTime startDate =
      DateTime.now().subtract(Duration(days: 30)); // Default to last 30 days
  DateTime endDate = DateTime.now(); // Default to today
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider = context.read<ExpenseProvider>();
      if (expenseProvider.expenses.isEmpty && !expenseProvider.isLoading) {
        expenseProvider.fetchExpenses();
      }
    });
  }

  void _updateFilter(DateTime newStartDate, DateTime newEndDate) {
    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
    });
  }

  Future<void> _selectCustomDateRange() async {
    final pickedDates = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (pickedDates != null) {
      _updateFilter(pickedDates.start, pickedDates.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          PopupMenuButton<String>(
            color: Colors.deepPurple[50],
            onSelected: (value) {
              if (value == 'weekly') {
                _updateFilter(
                  DateTime.now().subtract(Duration(days: 7)),
                  DateTime.now(),
                );
              } else if (value == 'monthly') {
                _updateFilter(
                  DateTime(DateTime.now().year, DateTime.now().month, 1),
                  DateTime.now(),
                );
              } else if (value == 'custom') {
                _selectCustomDateRange();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'weekly', child: Text('Last 7 Days')),
              PopupMenuItem(value: 'monthly', child: Text('This Month')),
              PopupMenuItem(value: 'custom', child: Text('Custom Range')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final filteredExpenses = expenseProvider.expenses.where((expense) {
            return expense.date.isAfter(startDate) &&
                expense.date.isBefore(endDate);
          }).toList();

          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (filteredExpenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses added yet!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              return Card(
                color: Colors.deepPurple[50],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // shape: BeveledRectangleBorder(
                  //   borderRadius: BorderRadius.circular(3.0),
                  // ),
                  // tileColor: Colors.lightdeepPurple[100],
                  title: Text(
                    expense.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Amount: Rs. ${expense.amount.toStringAsFixed(2)}\n'
                    'Date: ${DateFormat.yMMMd().format(expense.date)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     // Test immediate notification
                      //     await widget.notificationService
                      //         .scheduleImmediateNotification();
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //           content:
                      //               Text('Immediate Notification Scheduled')),
                      //     );
                      //   },
                      //   child: const Text('T'),
                      // ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditExpensePage(expense: expense),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, expenseProvider, expense.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditExpensePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ExpenseProvider provider, int expenseId) {
    showDialog(
      // barrierColor: Colors.deepPurple,
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deleteExpense(expenseId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
