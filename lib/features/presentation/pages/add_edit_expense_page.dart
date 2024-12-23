import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/expense_model.dart';
import '../provider/expense_provider.dart';

class AddEditExpensePage extends StatefulWidget {
  final ExpenseModel? expense;
  const AddEditExpensePage({Key? key, this.expense}) : super(key: key);

  @override
  _AddEditExpensePageState createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      // barrierColor: Colors.deepPurple[50],
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final description = _descriptionController.text;

      final expense = ExpenseModel(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch,
        amount: amount,
        description: description,
        date: _selectedDate ?? DateTime.now(),
      );

      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      if (widget.expense == null) {
        expenseProvider.addExpense(expense);
      } else {
        expenseProvider.deleteExpense(expense.id);
        expenseProvider.addExpense(expense);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                cursorColor: Colors.deepPurple,
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.deepPurple,
                  )),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.deepPurple,
                  )),
                  labelText: 'Amount',
                  focusColor: Colors.deepPurple,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: Colors.deepPurple,
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.deepPurple,
                  )),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'No Date Chosen!'
                        : 'Date: ${DateFormat.yMMMd().format(_selectedDate!.toLocal())}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text(
                      'Choose Date',
                      style: TextStyle(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                  Colors.deepPurple,
                )),
                onPressed: _saveExpense,
                child: Text(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    widget.expense == null ? 'Add Expense' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
