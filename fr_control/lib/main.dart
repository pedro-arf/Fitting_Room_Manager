import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fr_control/constants/routes.dart';
import 'package:fr_control/services/background/background_service.dart';
import 'package:fr_control/views/control_view.dart';
import 'package:fr_control/views/home_page.dart';
import 'package:fr_control/views/login_view.dart';
import 'package:fr_control/views/register_view.dart';
import 'package:fr_control/views/verify_email_view.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeBackgroundService();
  FlutterNativeSplash.removeAfter(initialization);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitting Room Control',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionHandleColor: Colors.black,
            selectionColor: Colors.grey[300],
          ),
          colorScheme: ColorScheme.fromSwatch(accentColor: Colors.white)),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        controlRoute: (context) => const ControlView(),
      },
    ),
  );
}

Future initialization(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 3));
}
