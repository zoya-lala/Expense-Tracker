import 'package:expense_tracker/features/data/expense_model.dart';
import 'package:expense_tracker/features/data/expense_repository.dart';
import 'package:flutter/material.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository repository;

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  ExpenseProvider(this.repository);

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await repository.getAllExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await repository.addExpense(expense);
    fetchExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await repository.deleteExpense(id);
    fetchExpenses();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await repository.updateExpense(expense);
    fetchExpenses();
  }
}
