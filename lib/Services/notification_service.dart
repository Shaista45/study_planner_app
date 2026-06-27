import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Android notification IDs should stay within signed 32-bit range.
  static const int _maxAndroidNotificationId = 0x7fffffff;
  static const int _taskIdBucketSize = 1000000000;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    await initializeNotificationEngine();
  }

  Future<void> initializeNotificationEngine() async {
    if (_isInitialized) return;

    final bool granted = await _requestNotificationPermission();

    if (granted) {
      await _configureLocalNotificationSettings();
      _isInitialized = true;
      debugPrint('Notification engine successfully primed on first install!');
    }
  }

  Future<bool> _requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool granted =
        await androidImplementation?.requestNotificationsPermission() ?? true;
    await androidImplementation?.requestExactAlarmsPermission();
    return granted;
  }

  Future<void> _configureLocalNotificationSettings() async {
    // The icon must match your Android app icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  int _taskNotificationBaseId(String taskId) {
    return (taskId.hashCode & _maxAndroidNotificationId) % _taskIdBucketSize;
  }

  int _taskCreatedNotificationId(String taskId) {
    return _taskNotificationBaseId(taskId) * 2;
  }

  int _taskDueNotificationId(String taskId) {
    return _taskNotificationBaseId(taskId) * 2 + 1;
  }

  Future<void> _scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationDetails notificationDetails,
  }) async {
    final tz.TZDateTime scheduledTzDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTzDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint(
        'Exact alarm scheduling failed for notification $id. Falling back to inexact mode. Error: $e',
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTzDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  String _formatDuration(Duration duration) {
    final int days = duration.inDays;
    final int hours = duration.inHours.remainder(24);
    final int minutes = duration.inMinutes.remainder(60);

    final List<String> parts = <String>[];
    if (days > 0) {
      parts.add('$days day${days == 1 ? '' : 's'}');
    }
    if (hours > 0) {
      parts.add('$hours hour${hours == 1 ? '' : 's'}');
    }
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
    }

    return parts.take(2).join(' and ');
  }

  String _formatRelativeDueText(DateTime deadline) {
    final Duration difference = deadline.difference(DateTime.now());
    if (difference.isNegative) {
      final Duration overdueBy = difference.abs();
      return 'was due ${_formatDuration(overdueBy)} ago';
    }

    return 'is due in ${_formatDuration(difference)}';
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) {
      await initializeNotificationEngine();
    }

    if (!_isInitialized) {
      debugPrint('Notification engine is not ready, skipping schedule.');
      return;
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_planner_channel',
        'Study Reminders',
        channelDescription: 'Reminders for upcoming study tasks',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
      debugPrint('Notification time already passed, showing immediately.');
      return;
    }

    await _scheduleZonedNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> showTaskCreatedNotification({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    if (!_isInitialized) {
      await initializeNotificationEngine();
    }

    if (!_isInitialized) {
      debugPrint('Notification engine is not ready, skipping created notice.');
      return;
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_planner_channel',
        'Study Reminders',
        channelDescription: 'Reminders for upcoming study tasks',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      id: _taskCreatedNotificationId(taskId),
      title: 'Task Created',
      body: 'Task "$taskTitle" ${_formatRelativeDueText(deadline)}.',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> scheduleTaskDueNotification({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    if (!_isInitialized) {
      await initializeNotificationEngine();
    }

    if (!_isInitialized) {
      debugPrint('Notification engine is not ready, skipping due notice.');
      return;
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_planner_channel',
        'Study Reminders',
        channelDescription: 'Reminders for upcoming study tasks',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    final DateTime now = DateTime.now();
    final int notificationId = _taskDueNotificationId(taskId);

    if (deadline.isBefore(now)) {
      await flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: 'Task Overdue',
        body: 'Task "$taskTitle" was not completed in time.',
        notificationDetails: notificationDetails,
      );
      return;
    }

    await _scheduleZonedNotification(
      id: notificationId,
      title: 'Task Overdue',
      body: 'Task "$taskTitle" was not completed in time.',
      scheduledDate: deadline,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    await cancelNotification(_taskCreatedNotificationId(taskId));
    await cancelNotification(_taskDueNotificationId(taskId));
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
