import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _notifications.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'studio_channel',
      'Studio Notifications',
      channelDescription: 'Notifications for studio events',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFB76E79),
    );
    
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(id, title, body, details);
  }
}
