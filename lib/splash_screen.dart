import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Make sure this points to your login screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1), // Fade-out duration
      vsync: this,
    );

    Timer(Duration(seconds: 3), () {
      _controller.forward();
      setState(() {
        _opacity = 0.0;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 1), // Fade-out duration
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '우리가 지금보다 더 아프지 않고\n 더 미치지 않은 것은\n '
                      '오로지 자연의 모든 은총 중에서도\n 가장 큰 축복인 잠 덕분이다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '- 올더스 헉슬리',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 15, // Set the width of the loading indicator
                  height: 15, // Set the height of the loading indicator
                  child: CircularProgressIndicator(), // Optional loading indicator
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
