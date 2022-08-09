import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int id = 1;

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
    var title,
    var body,
    var payload,
  }) async {
    id += 1;
    _notifications.show(id, title, body, await notificationDetails());
  }

  static notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id 2',
          'channel name',
          importance: Importance.max,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: IOSNotificationDetails());
  }
}
