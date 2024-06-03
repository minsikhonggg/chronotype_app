import 'package:flutter/material.dart';

class SleepAnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Sleep analysis will be shown here.',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
