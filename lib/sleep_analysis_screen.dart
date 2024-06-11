import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'package:intl/intl.dart';
import 'sleep_diary_screen.dart';

class SleepAnalysisScreen extends StatefulWidget {
  final VoidCallback onDiaryDeleted;
  final String email;

  SleepAnalysisScreen({required this.onDiaryDeleted, required this.email});

  @override
  _SleepAnalysisScreenState createState() => _SleepAnalysisScreenState();
}

class _SleepAnalysisScreenState extends State<SleepAnalysisScreen> {
  Map<String, List<Map<String, dynamic>>> _sleepDiariesByMonth = {};

  @override
  void initState() {
    super.initState();
    _loadSleepDiaries();
  }

  Future<void> _loadSleepDiaries() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries(widget.email);
    Map<String, List<Map<String, dynamic>>> diariesByMonth = {};

    for (var diary in diaries) {
      DateTime date = DateTime.parse(diary['date']);
      String monthKey = DateFormat('yyyy-MM').format(date);

      if (!diariesByMonth.containsKey(monthKey)) {
        diariesByMonth[monthKey] = [];
      }
      diariesByMonth[monthKey]!.add(diary);
    }

    diariesByMonth.forEach((key, value) {
      value.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']))); // 일기를 날짜 내림차순으로 정렬
    });

    // 월별 내림차순 정렬
    var sortedKeys = diariesByMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    Map<String, List<Map<String, dynamic>>> sortedDiariesByMonth = {
      for (var key in sortedKeys) key: diariesByMonth[key]!
    };

    setState(() {
      _sleepDiariesByMonth = sortedDiariesByMonth;
    });
  }

  Future<void> _deleteDiary(DateTime date) async {
    await DataService.deleteSleepDiary(date, widget.email);
    _loadSleepDiaries();
    widget.onDiaryDeleted(); // Notify the calendar to update
  }

  Future<void> _deleteAllDiaries() async {
    for (var month in _sleepDiariesByMonth.keys) {
      await _deleteDiariesByMonth(month);
    }
    _loadSleepDiaries();
    widget.onDiaryDeleted(); // Notify the calendar to update
  }

  Future<void> _deleteDiariesByMonth(String month) async {
    final diariesInMonth = _sleepDiariesByMonth[month];
    if (diariesInMonth != null) {
      for (var diary in diariesInMonth) {
        DateTime date = DateTime.parse(diary['date']);
        await _deleteDiary(date);
      }
      _loadSleepDiaries(); // Reload the list after deletion
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  Future<void> _navigateToSleepDiaryScreen(DateTime selectedDate, String email, String? existingDiary) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepDiaryScreen(
          selectedDate: selectedDate,
          email: email,
          existingDiary: existingDiary,
        ),
      ),
    );
    _loadSleepDiaries(); // Reload diaries after potential updates
  }

  Future<void> _showSleepDiaryDialog(DateTime selectedDate) async {
    final existingDiary = await DataService.getDiaryByDate(selectedDate, widget.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: existingDiary != null
              ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existingDiary['diary']),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToSleepDiaryScreen(selectedDate, widget.email, existingDiary['diary']);
                    },
                    child: Text('수정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(selectedDate);
                    },
                    child: Text('삭제'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
              : Text('작성된 수면 일기가 없습니다.'),
          actions: [
            if (existingDiary == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSleepDiaryScreen(selectedDate, widget.email, null);
                },
                child: Text('추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(DateTime date) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            '삭제 확인',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('정말 삭제 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('돌아가기'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteDiary(date);
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close sleep diary dialog
                _showDeletionSuccessDialog(); // Show deletion success dialog
              },
              child: Text('삭제'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[200], // Light red color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            '모두 삭제 확인',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('정말 모든 수면 일기를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('돌아가기'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteAllDiaries();
                Navigator.pop(context); // Close confirmation dialog
                _showDeletionSuccessDialog(); // Show deletion success dialog
              },
              child: Text('삭제'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            '삭제 완료',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('수면 일기가 삭제되었습니다.'),
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
        title: Text('Sleep Analysis'),
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
        child: _sleepDiariesByMonth.isEmpty
            ? Center(
          child: Text(
            'No sleep diaries found.',
            style: TextStyle(fontSize: 20),
          ),
        )
            : ListView(
          children: _sleepDiariesByMonth.entries.map((entry) {
            return ExpansionTile(
              title: Text(
                entry.key,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: entry.value.map((diary) {
                final date = DateTime.parse(diary['date']);
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      _formatDate(diary['date']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(diary['diary']),
                    onTap: () {
                      _showSleepDiaryDialog(date);
                    },
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
