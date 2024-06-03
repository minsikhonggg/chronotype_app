import 'package:flutter/material.dart';

class SleepDiaryScreen extends StatelessWidget {
  final DateTime selectedDate;

  SleepDiaryScreen({required this.selectedDate});

  final TextEditingController _diaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${selectedDate.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _diaryController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Enter your sleep diary here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 일기 저장 로직 추가
                Navigator.pop(context, _diaryController.text);
              },
              child: Text('Save Diary Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
