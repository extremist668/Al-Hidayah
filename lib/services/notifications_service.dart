import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

class NotificationsService {
  static final NotificationsService instance = NotificationsService._internal();
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('NotificationsService initialized on Web (Muted/Mocked).');
      return;
    }

    tz.initializeTimeZones();

    // Android Initialization Settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click event
      },
    );

    // Create a special High Importance channel for Azan Alarms
    const AndroidNotificationChannel azanChannel = AndroidNotificationChannel(
      'azan_channel_id',
      'Azan Alarms',
      description: 'This channel is used for daily prayer notifications (Azan).',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan_sound'), // place in res/raw/azan_sound.mp3
      enableVibration: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(azanChannel);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      debugPrint('Web Notification: [$title] - $body');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'general_channel_id',
      'General Notifications',
      channelDescription: 'General app reminders and announcements',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleAzanNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    if (kIsWeb) {
      debugPrint('Web Schedule Notification: [$title] at $scheduledDateTime');
      return;
    }

    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'azan_channel_id',
      'Azan Alarms',
      channelDescription: 'This channel is used for daily prayer notifications (Azan).',
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('azan_sound'),
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _localNotificationsPlugin.cancelAll();
  }
}

// Background Worker implementation using Workmanager (Android Only)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // This background task runs periodically to sync prayer logs & pull schedules
    try {
      // Offline sync mechanism logic can be triggered here
      return true;
    } catch (e) {
      return false;
    }
  });
}
