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
    List<ConnectivityResult> resultList;
    try {
      resultList = await _connectivity.checkConnectivity();
    } catch (e) {
      resultList = [ConnectivityResult.none]; // Default to none if error occurs
    }

    if (!mounted) {
      return;
    }

    if (resultList.isNotEmpty) {
      _updateConnectionStatus(resultList[0]); // Use the first item of the list
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });

    String message;
    Color backgroundColor;

    if (result == ConnectivityResult.none) {
      message = 'No Internet Connection';
      backgroundColor = Colors.red;
    } else {
      bool hasInternet = await _checkInternetAccess();
      if (hasInternet) {
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
      } else {
        message = 'No Internet Access';
        backgroundColor = Colors.orange;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: 3),
        ),
      );
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

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // String statusMessage;
    // IconData statusIcon;

    // switch (_connectionStatus) {
    //   case ConnectivityResult.wifi:
    //     // statusMessage = 'Connected to Wi-Fi';
    //     statusIcon = Icons.wifi;
    //     break;
    //   case ConnectivityResult.mobile:
    //     // statusMessage = 'Connected to Mobile Network';
    //     statusIcon = Icons.signal_cellular_alt;
    //     break;
    //   case ConnectivityResult.none:
    //   default:
    //     // statusMessage = 'No Internet Connection';
    //     statusIcon = Icons.signal_wifi_off;
    //     break;
    // }

    // return Row(

    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Icon(statusIcon, color: Colors.green ) ,

    //     SizedBox(width: 10),

    //     // Text(
    //     //   statusMessage,
    //     //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //     // ),
    //   ],
    // );
  }
}
