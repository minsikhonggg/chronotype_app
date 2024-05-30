import 'package:flutter/material.dart';

class SleepDiaryPage extends StatefulWidget {
  @override
  _SleepDiaryPageState createState() => _SleepDiaryPageState();
}

class _SleepDiaryPageState extends State<SleepDiaryPage> {
  final List<String> _answers = List.filled(11, '');

  void _saveDiary() {
    // 수면 일기 저장 로직 구현
    print(_answers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sleep Diary')),
      body: ListView.builder(
        itemCount: 11,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Guide Question ${index + 1}'),
            subtitle: TextField(
              onChanged: (value) {
                _answers[index] = value;
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveDiary,
        child: Icon(Icons.save),
      ),
    );
  }
}
