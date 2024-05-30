import 'package:flutter/material.dart';

class SleepAnalysisPage extends StatelessWidget {
  final List<String> sleepDiary;

  SleepAnalysisPage(this.sleepDiary);

  @override
  Widget build(BuildContext context) {
    String analysis = _analyzeSleepDiary(sleepDiary);

    return Scaffold(
      appBar: AppBar(title: Text('Sleep Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(analysis),
      ),
    );
  }

  String _analyzeSleepDiary(List<String> diary) {
    // 분석 로직 구현 (예: 단순 텍스트 분석)
    return 'Analysis result based on diary: ${diary.join(', ')}';
  }
}
