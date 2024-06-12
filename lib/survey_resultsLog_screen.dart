import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'package:intl/intl.dart';

class SurveyResultsLogScreen extends StatefulWidget {
  final String email;
  final VoidCallback onResultsDeleted;
  const SurveyResultsLogScreen({Key? key, required this.email, required this.onResultsDeleted}) : super(key: key);

  @override
  _SurveyResultsLogScreenState createState() => _SurveyResultsLogScreenState();
}

class _SurveyResultsLogScreenState extends State<SurveyResultsLogScreen> {
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
    _loadResults();
    widget.onResultsDeleted();
  }

  Future<void> _deleteAllResults() async {
    await DataService.deleteAllChronotypeResults(widget.email);
    _loadResults();
    widget.onResultsDeleted();
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말 삭제 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteResult(id);
                _showDeletionSuccessDialog();
              },
              child: const Text('삭제'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
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
          title: const Text('모두 삭제 확인'),
          content: const Text('정말 모든 설문 조사 결과를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close confirmation dialog
                await _deleteAllResults();
                _showDeletionSuccessDialog();
              },
              child: const Text('삭제'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Light red color
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
          title: const Text('삭제 완료'),
          content: const Text('설문 조사 결과가 삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('닫기', style: TextStyle(color: Colors.black)),
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
        title: const Text('설문 조사 결과 관리',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _showDeleteAllConfirmationDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _results.isEmpty
            ? const Center(
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('결과: ${result['resultType']}'),
                    Text('점수: ${result['score']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
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
