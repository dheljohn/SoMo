import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/dashB.dart';
import 'package:soil_monitoring_app/fcm_service.dart';
import 'package:soil_monitoring_app/home.dart';
import 'package:soil_monitoring_app/start_page.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart'; // Don't forget this
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:soil_monitoring_app/tts_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
  ]);

  // await Firebase.initializeApp();
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyA_lQLKsXD_SGL4QyEVO3HEFUgJUcQW0sQ",
              authDomain: "test-monitor-reui.firebaseapp.com",
              databaseURL:
                  "https://test-monitor-reui-default-rtdb.asia-southeast1.firebasedatabase.app",
              projectId: "test-monitor-reui",
              storageBucket: "test-monitor-reui.firebasestorage.app",
              messagingSenderId: "367476307418",
              appId: "1:367476307418:web:2cf68b6cba4b8189d1fce3"));
      // await LocalNotification.init();
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            ChangeNotifierProvider(
                create: (context) => TtsProvider()), // Add this
          ],
          child: DevicePreview(
            enabled: kReleaseMode, //comment this line to disable device preview
            builder: (context) => MaterialApp(
              useInheritedMediaQuery: true,
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
              home: SplashScreen(), //undo comment to enable splash screen
              // home: Home(), //comment for debugging
              debugShowCheckedModeBanner: false,
            ),
          ),
        ),
      );
    } catch (e) {
      print('An error occurred: $e');
    }

    //
  } else {
    try {
      await Firebase.initializeApp();
      // await LocalNotification.init();
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            ChangeNotifierProvider(
                create: (context) => TtsProvider()), // Add this
          ],
          child: DevicePreview(
            enabled: kReleaseMode, //comment this line to disable device preview
            builder: (context) => MaterialApp(
              useInheritedMediaQuery: true,
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
              home: SplashScreen(), //undo comment to enable splash screen
              // home: Home(), //comment for debugging
              debugShowCheckedModeBanner: false,
            ),
          ),
        ),
      );
    } catch (e) {
      print('An error occurred: $e');
    }

    // await FirebaseMessaging.instance.subscribeToTopic("test_soil");

    // final fcmToken = await FirebaseMessaging.instance.getToken();

    // print('fcm Token: $fcmToken');

    final FCMService fcmService = FCMService();
    await fcmService.saveOrUpdateFCMToken();
  }

  // runApp(const MaterialApp(
  //   home: Home(),
  //   debugShowCheckedModeBanner: false,
  // ));
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MaterialApp(
//     home: Home(),
//     debugShowCheckedModeBanner: false,
//   ));
// }
