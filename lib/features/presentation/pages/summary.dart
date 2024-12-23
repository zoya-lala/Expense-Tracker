import 'package:expense_tracker/features/data/expense_repository.dart';
import 'package:flutter/material.dart';

class ExpenseSummaryPage extends StatefulWidget {
  final ExpenseRepository repository;

  const ExpenseSummaryPage({Key? key, required this.repository})
      : super(key: key);

  @override
  _ExpenseSummaryPageState createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

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
        title: const Text('Expense Summary'),
        actions: [
          PopupMenuButton<String>(
            // shadowColor: Colors.deepPurple[100],
            // surfaceTintColor: Colors.deepPurple[100],
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
      body: FutureBuilder<Map<String, double>>(
        future: widget.repository.getExpenseSummary(
          startDate: startDate,
          endDate: endDate,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final summary = snapshot.data!;
            return ListView(
              children: summary.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    'Rs.${entry.value.toStringAsFixed(2)}',
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('No expenses found.'));
          }
        },
      ),
    );
  }
}
