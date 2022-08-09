import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationWidget {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init({bool scheduled = false}) async {
    var initAndroidSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = const IOSInitializationSettings();
    final settings =
        InitializationSettings(android: initAndroidSettings, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future showNotification({
    var id = 0,
    var title,
    var body,
    var payload,
  }) async =>
      _notifications.show(id, title, body, await notificationDetails());

  static notificationDetails() async {
    var id = Random();
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id 2',
          'channel name',
          importance: Importance.max,
          styleInformation: const BigTextStyleInformation(''),
        ),
        iOS: IOSNotificationDetails());
  }
}
