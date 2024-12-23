import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initializeDatabase() async {
  final path = await getDatabasesPath();
  return openDatabase(
    join(path, 'expenses.db'),
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY,
          amount REAL,
          description TEXT,
          date INTEGER
        )
      ''');
    },
    version: 1,
  );
}
