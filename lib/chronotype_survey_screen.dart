import 'package:flutter/material.dart';
import 'services/data_service.dart';

class ChronotypeSurveyScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _questions = [
    {'question': 'What time do you usually wake up?', 'options': ['5-6 AM', '6-7 AM', '7-8 AM', '8-9 AM', 'After 9 AM']},
    // 추가 질문을 여기에 추가하세요
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chronotype Survey')),
      body: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_questions[index]['question']),
            trailing: DropdownButton<String>(
              items: _questions[index]['options'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                DataService.saveSurveyAnswer(index, newValue!);
              },
            ),
          );
        },
      ),
    );
  }
}
