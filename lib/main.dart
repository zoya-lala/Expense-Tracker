import 'package:expense_tracker/features/data/database_helper.dart';
import 'package:expense_tracker/features/data/expense_repository.dart';
import 'package:expense_tracker/features/presentation/pages/expense_list_page.dart';
import 'package:expense_tracker/features/presentation/provider/expense_provider.dart';
import 'package:expense_tracker/services/notify.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.scheduleDailyReminder();

  final database = await initializeDatabase();
  final repository = ExpenseRepository(database: database);

  runApp(
      MyApp(repository: repository, notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final ExpenseRepository repository;
  final NotificationService notificationService;

  const MyApp({required this.repository, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(repository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Expense Tracker',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: ExpenseListPage(
          notificationService: notificationService,
        ),
      ),
    );
  }
}
