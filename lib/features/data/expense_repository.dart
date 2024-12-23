import 'package:sqflite/sqflite.dart';

import '../data/expense_model.dart';

class ExpenseRepository {
  final Database database;

  ExpenseRepository({required this.database});

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY,
        amount REAL,
        description TEXT,
        type TEXT,
        date INTEGER
      )
    ''');
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final List<Map<String, dynamic>> expenseMaps =
        await database.query('expenses');
    return expenseMaps.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await database.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExpense(int id) async {
    await database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await database.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<Map<String, double>> getExpenseSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await database.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM expenses
      WHERE date >= ? AND date <= ?
      GROUP BY type
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

    return Map.fromEntries(result.map((row) {
      return MapEntry(row['type'] as String, (row['total'] as num).toDouble());
    }));
  }
}
