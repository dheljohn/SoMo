import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class WifiStatus extends StatefulWidget {
  @override
  _WifiStatusState createState() => _WifiStatusState();
}

class _WifiStatusState extends State<WifiStatus> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? _hintMessage;
  Color? _hintColor;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> resultList) {
      if (resultList.isNotEmpty) {
        _updateConnectionStatus(resultList[0]);
      }
    });
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult result;
    try {
      result = (await _connectivity.checkConnectivity()) as ConnectivityResult;
    } catch (e) {
      result = ConnectivityResult.none; // Default to none if error occurs
    }

    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
    }

    String message;
    Color backgroundColor;

    if (result == ConnectivityResult.none) {
      message = 'Waiting for Internet Connection';
      backgroundColor = const Color.fromARGB(255, 216, 186, 15);
    } else {
      bool hasInternet = await _checkInternetAccess();
      if (hasInternet) {
        bool isSlow = await _checkInternetSpeed();
        if (isSlow) {
          message = 'Internet Connection is Slow';
          backgroundColor = const Color.fromARGB(255, 151, 137, 8);
        } else {
          switch (result) {
            case ConnectivityResult.wifi:
              message = 'Connected to Wi-Fi with Internet';
              backgroundColor = Colors.green;
              break;
            case ConnectivityResult.mobile:
              message = 'Connected to Mobile Network with Internet';
              backgroundColor = Colors.blue;
              break;
            default:
              message = 'Connected with Internet';
              backgroundColor = Colors.green;
              break;
          }
        }
      } else {
        message = 'No Internet Access';
        backgroundColor = Colors.orange;
      }
    }

    if (mounted) {
      setState(() {
        _hintMessage = message;
        _hintColor = backgroundColor;
      });

      // Hide the hint message after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _hintMessage = null;
            _hintColor = null;
          });
        }
      });
    }
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> _checkInternetSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse('https://www.google.com'));
      stopwatch.stop();
      if (response.statusCode == 200) {
        // Consider the connection slow if it takes more than 2 seconds
        return stopwatch.elapsedMilliseconds > 2000;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(), // Your main content goes here
        if (_hintMessage != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _hintColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.info,
                  //   color: Colors.white,
                  // ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hintMessage!,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
