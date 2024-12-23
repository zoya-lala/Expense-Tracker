import 'package:expense_tracker/features/presentation/pages/expense_list_page.dart';
import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    final AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    print('Notification Service Initialized');
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ExpenseListPage(),
      ),
    );
  }

  Future<void> scheduleDailyReminder() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      1,
      46,
    );

    final tz.TZDateTime finalScheduledTime = scheduledTime.isBefore(now)
        ? scheduledTime.add(Duration(days: 1))
        : scheduledTime;

    print('Scheduling notification for: $finalScheduledTime');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      'Time to track your expenses!',
      finalScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_tracker_channel_id',
          'Expense Tracker',
          channelDescription: 'Reminders to track daily expenses',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Notification scheduled successfully.');
  }

  Future<void> scheduleImmediateNotification() async {
    final now = tz.TZDateTime.now(tz.local)
        .add(Duration(seconds: 5)); // 5 seconds delay
    print('Scheduling immediate notification for: $now');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Immediate Test',
      'This should appear in 5 seconds.',
      now,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );

    print('Immediate notification scheduled.');
  }
}
