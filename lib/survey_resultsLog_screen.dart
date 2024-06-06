import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'package:intl/intl.dart';

class SurveyResultsScreen extends StatefulWidget {
  final String email;
  final VoidCallback onResultsDeleted;

  SurveyResultsScreen({required this.email, required this.onResultsDeleted});

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

  Future<void> _deleteResult(int id) async {
    await DataService.deleteChronotypeResult(id);
    _loadResults(); // Refresh the list after deletion
    widget.onResultsDeleted(); // Notify the profile screen to update
  }

  Future<void> _deleteAllResults() async {
    await DataService.deleteAllChronotypeResults(widget.email);
    _loadResults(); // Refresh the list after deletion
    widget.onResultsDeleted(); // Notify the profile screen to update
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말 삭제 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('돌아가기'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close confirmation dialog
                await _deleteResult(id);
                _showDeletionSuccessDialog();
              },
              child: Text('삭제'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[200], // Light red color
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAllConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('모두 삭제 확인'),
          content: Text('정말 모든 설문 조사 결과를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('돌아가기'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close confirmation dialog
                await _deleteAllResults();
                _showDeletionSuccessDialog();
              },
              child: Text('삭제'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[200], // Light red color
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeletionSuccessDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제 완료'),
          content: Text('설문 조사 결과가 삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close success dialog
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설문 조사 결과 관리'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _showDeleteAllConfirmationDialog();
            },
          ),
        ],
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
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _showDeleteConfirmationDialog(result['id']);
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
