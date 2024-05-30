import 'package:flutter/material.dart';

class ChronotypeSurveyPage extends StatefulWidget {
  @override
  _ChronotypeSurveyPageState createState() => _ChronotypeSurveyPageState();
}

class _ChronotypeSurveyPageState extends State<ChronotypeSurveyPage> {
  final List<int> _answers = List.filled(19, 0);

  void _submitSurvey() {
    int totalScore = _answers.reduce((a, b) => a + b);
    String chronotype = _determineChronotype(totalScore);
    // 결과를 사용자에게 보여줌
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Your Chronotype'),
        content: Text(chronotype),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _determineChronotype(int score) {
    if (score <= 30) return 'Definite Evening Type';
    if (score <= 41) return 'Moderate Evening Type';
    if (score <= 58) return 'Intermediate Type';
    if (score <= 69) return 'Moderate Morning Type';
    return 'Definite Morning Type';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chronotype Survey')),
      body: ListView.builder(
        itemCount: 19,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Question ${index + 1}'),
            trailing: DropdownButton<int>(
              value: _answers[index],
              items: List.generate(5, (i) => DropdownMenuItem(child: Text('$i'), value: i)),
              onChanged: (value) {
                setState(() {
                  _answers[index] = value!;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitSurvey,
        child: Icon(Icons.check),
      ),
    );
  }
}
