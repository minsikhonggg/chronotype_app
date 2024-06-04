import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'package:intl/intl.dart';

class SleepAnalysisScreen extends StatefulWidget {
  final VoidCallback onDiaryDeleted;

  SleepAnalysisScreen({required this.onDiaryDeleted});

  @override
  _SleepAnalysisScreenState createState() => _SleepAnalysisScreenState();
}

class _SleepAnalysisScreenState extends State<SleepAnalysisScreen> {
  List<Map<String, dynamic>> _sleepDiaries = [];

  @override
  void initState() {
    super.initState();
    _loadSleepDiaries();
  }

  Future<void> _loadSleepDiaries() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries();
    setState(() {
      _sleepDiaries = diaries;
    });
  }

  Future<void> _deleteDiary(DateTime date) async {
    await DataService.deleteSleepDiary(date);
    _loadSleepDiaries();
    widget.onDiaryDeleted(); // Notify the calendar to update
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sleepDiaries.isEmpty
            ? Center(
          child: Text(
            'No sleep diaries found.',
            style: TextStyle(fontSize: 20),
          ),
        )
            : ListView.builder(
          itemCount: _sleepDiaries.length,
          itemBuilder: (context, index) {
            final diary = _sleepDiaries[index];
            final date = DateTime.parse(diary['date']);
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  _formatDate(diary['date']),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(diary['diary']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteDiary(date);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
