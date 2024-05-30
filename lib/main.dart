import 'package:flutter/material.dart';
import 'login_page.dart';
import 'chronotype_survey_page.dart';
import 'sleep_diary_page.dart';
import 'sleep_analysis_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronotype App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chronotype App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/chronotypeSurvey'),
              child: const Text('Chronotype Survey'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/sleepDiary'),
              child: const Text('Sleep Diary'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/sleepAnalysis'),
              child: const Text('Sleep Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
