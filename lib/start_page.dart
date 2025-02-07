import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 125, 171, 124),
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 150, 
          height: 150,
        ),
      ),
    );
  }
}
