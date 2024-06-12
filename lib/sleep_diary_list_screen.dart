import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/data_service.dart';
import 'sleep_diary_screen.dart';

class SleepDiaryListScreen extends StatefulWidget {
  final VoidCallback onDiaryDeleted;
  final String email;

  SleepDiaryListScreen({required this.onDiaryDeleted, required this.email});

  @override
  _SleepDiaryListScreenState createState() => _SleepDiaryListScreenState();
}

class _SleepDiaryListScreenState extends State<SleepDiaryListScreen> {
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
    return DateFormat('< yyyy-MM-dd >').format(parsedDate);
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
            DateFormat('< yyyy-MM-dd >').format(selectedDate),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: existingDiary != null
                ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildSurveyStyleEntries(existingDiary['diary']),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToSleepDiaryScreen(selectedDate, widget.email, existingDiary['diary']);
                      },
                      child: Text('수정', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(selectedDate);
                      },
                      child: Text('삭제', style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            )
                : Text('작성된 수면 일기가 없습니다.'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('닫기', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSurveyStyleEntries(String diary) {
    final lines = diary.split('\n');
    return lines.map((line) {
      final parts = line.split(':');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parts[0] + (parts.length > 1 ? ':' : ''),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),
            ),
            if (parts.length > 1)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  parts.sublist(1).join(':'),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _showDeleteConfirmationDialog(DateTime date) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제 확인', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: Text('정말 삭제 하시겠습니까?', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteDiary(date);
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close sleep diary dialog
                _showDeletionSuccessDialog(); // Show deletion success dialog
              },
              child: Text('삭제', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
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
              child: Text('취소', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteAllDiaries();
                Navigator.pop(context); // Close confirmation dialog
                _showDeletionSuccessDialog(); // Show deletion success dialog
              },
              child: Text('삭제', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
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
          title: Text('삭제 완료', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: Text('수면 일기가 삭제되었습니다.', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('닫기', style: TextStyle(color: Colors.black)),
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
        title: Text(
          '수면 일기 목록',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildSurveyStyleEntries(diary['diary']),
                    ),
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
