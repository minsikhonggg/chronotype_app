import 'package:flutter/material.dart';

class ChronotypeSurveyScreen extends StatefulWidget {
  @override
  _ChronotypeSurveyScreenState createState() => _ChronotypeSurveyScreenState();
}

class _ChronotypeSurveyScreenState extends State<ChronotypeSurveyScreen> {
  final List<String> questions = [
    'Question 1',
    'Question 2',
    // Add all 19 questions here
  ];

  final Map<int, int> answers = {};

  void _submitSurvey() {
    int totalScore = answers.values.reduce((a, b) => a + b);
    String chronotype = _determineChronotype(totalScore);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(chronotype: chronotype),
      ),
    );
  }

  String _determineChronotype(int score) {
    if (score <= 19) return 'Definitely Evening Type';
    if (score <= 39) return 'Moderate Evening Type';
    if (score <= 59) return 'Intermediate Type';
    if (score <= 79) return 'Moderate Morning Type';
    return 'Definitely Morning Type';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chronotype Survey')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questions[index]),
            trailing: DropdownButton<int>(
              value: answers[index],
              items: List.generate(5, (i) => i + 1)
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  answers[index] = value!;
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

class ResultScreen extends StatelessWidget {
  final String chronotype;

  ResultScreen({required this.chronotype});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Chronotype')),
      body: Center(
        child: Text('Your chronotype is $chronotype'),
      ),
    );
  }
}
