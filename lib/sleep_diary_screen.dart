import 'package:flutter/material.dart';

class SleepDiaryScreen extends StatefulWidget {
  @override
  _SleepDiaryScreenState createState() => _SleepDiaryScreenState();
}

class _SleepDiaryScreenState extends State<SleepDiaryScreen> {
  final List<String> questions = [
    'What time did you go to bed?',
    'How long did it take you to fall asleep?',
    // Add all 11 questions here
  ];

  final Map<int, String> answers = {};

  void _submitDiary() {
    // Save the answers to a database or process them as needed
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sleep Diary')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questions[index]),
            trailing: TextField(
              onChanged: (value) {
                answers[index] = value;
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitDiary,
        child: Icon(Icons.check),
      ),
    );
  }
}
