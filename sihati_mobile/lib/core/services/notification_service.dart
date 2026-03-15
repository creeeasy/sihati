import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ─── Initialize ───────────────────────────────────────────────

  Future<void> initialize() async {
    // Must init timezone data before any tz.local usage
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android — use Darwin equivalent name for iOS
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    // iOS — DarwinFlutterLocalNotificationsPlugin (not iOS-specific anymore)
    final darwin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await darwin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: navigate to medication detail using response.payload (medication name)
  }

  // ─── Schedule Reminders ───────────────────────────────────────

  Future<void> scheduleMedicationReminders({
    required String medicationName,
    required List<TimeOfDay> times,
  }) async {
    // Cancel any existing reminders for this medication first
    await cancelMedicationReminders(medicationName);

    final now = DateTime.now();

    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final id = _generateNotificationId(medicationName, i);

      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id: id,
        title: '💊 Rappel médicament',
        body: 'Il est temps de prendre $medicationName',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Rappels de médicaments',
            channelDescription:
                'Notifications pour les rappels de prise de médicaments',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medicationName,
      );
    }
  }

  // ─── Cancel ───────────────────────────────────────────────────

  Future<void> cancelMedicationReminders(String medicationName) async {
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel(
          id: _generateNotificationId(medicationName, i));
    }
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // ─── Pending ──────────────────────────────────────────────────

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _notifications.pendingNotificationRequests();
  }

  // ─── Helpers ──────────────────────────────────────────────────

  int _generateNotificationId(String medicationName, int index) {
    return (medicationName.hashCode.abs() % 100000) + index;
  }
}
