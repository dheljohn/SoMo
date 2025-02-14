import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:soil_monitoring_app/dashB.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/historySection.dart';
import 'package:soil_monitoring_app/navBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AppBar appBar = AppBar(
    backgroundColor: const Color.fromARGB(255, 125, 171, 124),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    title: Row(
      children: [
        const SizedBox(width: 80),
        Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
        ),
      ],
    ),
  );

  int _currentIndex = 0;
  double humidity_v = 0.0;
  double temperature_v = 0.0;
  double moisture_a = 0.0;
  double moisture_s1 = 0.0;
  double moisture_s2 = 0.0;
  double moisture_s3 = 0.0;
  double moisture_s4 = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchDataFromFirebase();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'soil_monitoring_channel',
      'Soil Monitoring Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_sound'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Soil Moisture Alert',
      message,
      platformChannelSpecifics,
    );
  }

  void _fetchDataFromFirebase() {
    DatabaseReference _humidityRef =
        FirebaseDatabase.instance.ref().child('Humidity/humidity');
    DatabaseReference _temperatureRef =
        FirebaseDatabase.instance.ref().child('Temperature/temperature');
    DatabaseReference _moistureAvgRef =
        FirebaseDatabase.instance.ref().child('Moisture/Average');
    DatabaseReference _moistureDataRef =
        FirebaseDatabase.instance.ref().child('Moisture');

    // Fetch Humidity
    _humidityRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() {
        humidity_v = value;
      });
    });

    // Fetch Temperature
    _temperatureRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() {
        temperature_v = value;
      });
    });

    // Fetch Moisture Average
    _moistureAvgRef.once().then((event) {
      double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      setState(() {
        moisture_a = value;
      });

      // Check for Dry or Wet conditions
      if (value < 40) {
        _showNotification('Soil moisture is too dry! Consider watering.');
      } else if (value > 80) {
        _showNotification('Soil is too wet! Consider reducing watering.');
      }
    });

    // Fetch Moisture Data
    _moistureDataRef.once().then((event) {
      final value = event.snapshot.value as Map?;
      if (value != null) {
        double moisture1 =
            double.tryParse(value['MoistureReadings_1']?.toString() ?? '') ??
                0.0;
        double moisture2 =
            double.tryParse(value['MoistureReadings_2']?.toString() ?? '') ??
                0.0;
        double moisture3 =
            double.tryParse(value['MoistureReadings_3']?.toString() ?? '') ??
                0.0;
        double moisture4 =
            double.tryParse(value['MoistureReadings_4']?.toString() ?? '') ??
                0.0;

        setState(() {
          moisture_s1 = moisture1;
          moisture_s2 = moisture2;
          moisture_s3 = moisture3;
          moisture_s4 = moisture4;
        });
        // Check individual sensor readings
        if (moisture1 < 40 ||
            moisture2 < 40 ||
            moisture3 < 40 ||
            moisture4 < 40) {
          _showNotification('One of the sensors detected dry soil.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataProvider(
      humidityValue: humidity_v,
      temperatureValue: temperature_v,
      moistureA: moisture_a,
      moistureS1: moisture_s1,
      moistureS2: moisture_s2,
      moistureS3: moisture_s3,
      moistureS4: moisture_s4,
      child: Scaffold(
        drawer: navBar(),
        appBar: appBar,
        body: IndexedStack(
          index: _currentIndex,
          children: [const DashB(), SensorHistoryScreen()],
        ),
        bottomNavigationBar: MotionTabBar(
          labels: ['Dashboard', 'History'],
          initialSelectedTab: 'Dashboard',
          icons: [Icons.dashboard, Icons.history],
          tabSize: 50,
          tabBarHeight: 60,
          textStyle: TextStyle(
            color: Color.fromARGB(255, 53, 51, 51),
            fontWeight: FontWeight.bold,
          ),
          tabIconColor: Colors.grey,
          tabIconSelectedColor: Colors.white,
          tabBarColor: Color.fromARGB(255, 255, 255, 255),
          tabSelectedColor: const Color.fromARGB(255, 125, 171, 124),
          onTabItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  navBar() {
    return Navbar();
  }
}
