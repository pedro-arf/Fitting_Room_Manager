import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fr_control/utilities/notification_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  return true;
}

void onStart(ServiceInstance service) async {
  var counter = 0;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('state');

  if (service is AndroidServiceInstance) {
    DartPluginRegistrant.ensureInitialized();

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final String? state = prefs.getString('state');

      if (state == 'paused') {
        counter++;
      } else {
        counter = 0;
      }
      service.setForegroundNotificationInfo(
        title: "Fitting Room Control",
        content: "Please keep checking the app from  time to time.",
      );
      if (counter == 1800) {
        NotificationWidget.showNotification(
            title: 'Alert',
            body:
                'Please check the app to see if items were left in the fitting room.');
        counter = 0;
      }
    });
  }
}
