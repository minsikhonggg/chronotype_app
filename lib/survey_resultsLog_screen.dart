import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'package:intl/intl.dart';

class SurveyResultsScreen extends StatefulWidget {
  final String email;

  SurveyResultsScreen({required this.email});

  @override
  _SurveyResultsScreenState createState() => _SurveyResultsScreenState();
}

class _SurveyResultsScreenState extends State<SurveyResultsScreen> {
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await DataService.getChronotypeResults(widget.email);
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설문 조사 결과 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _results.isEmpty
            ? Center(
          child: Text('설문 조사 결과가 없습니다.'),
        )
            : ListView.builder(
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final result = _results[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  DateFormat('yyyy-MM-dd').format(DateTime.parse(result['date'])),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('결과: ${result['resultType']}'),
                    Text('점수: ${result['score']}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
