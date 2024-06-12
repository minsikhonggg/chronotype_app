import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'profile_screen.dart';
import 'sleep_diary_screen.dart';
import 'sleep_diary_list_screen.dart';
import 'services/data_service.dart';
import 'bottom_navigation_bar.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<DateTime, String> sleepDiary = {};
  int _currentIndex = 0;
  DateTime _focusedDay = DateTime.now();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSleepDiaries();
  }

  Future<void> _loadSleepDiaries() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries(widget.email);
    setState(() {
      sleepDiary = {
        for (var diary in diaries) DateTime.parse(diary['date']): diary['diary']
      };
    });
  }

  Future<void> _showSleepDiaryDialog(DateTime selectedDate) async {
    final diaryEntry = await DataService.getDiaryByDate(selectedDate, widget.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(DateFormat('< yyyy-MM-dd >').format(selectedDate),
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: diaryEntry != null
              ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildSurveyStyleEntries(diaryEntry['diary']),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToSleepDiaryScreen(selectedDate, diaryEntry['diary']);
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
            ),
          )
              : Text('작성된 수면 일기가 없습니다.', style: TextStyle(color: Colors.black)),
          actions: [
            if (diaryEntry == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSleepDiaryScreen(selectedDate, null);
                },
                child: Text('추가', style: TextStyle(color: Colors.black)),
              ),
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

  Future<void> _navigateToSleepDiaryScreen(DateTime selectedDate, String? existingDiary) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepDiaryScreen(
          selectedDate: selectedDate,
          email: widget.email,
          existingDiary: existingDiary,
        ),
      ),
    );
    _loadSleepDiaries();
  }

  Future<void> _showDeleteConfirmationDialog(DateTime selectedDate) async {
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
                await DataService.deleteSleepDiary(selectedDate, widget.email);
                Navigator.pop(context);
                Navigator.pop(context);
                _showDeletionSuccessDialog();
                _loadSleepDiaries();
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

  Widget _buildDiaryEntry(String diary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: diary.split('\n').map((line) {
        final parts = line.split(':');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: RichText(
            text: TextSpan(
              text: parts[0] + (parts.length > 1 ? ':' : ''),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
              children: parts.length > 1
                  ? [
                TextSpan(
                  text: parts.sublist(1).join(':'),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ]
                  : [],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<DateTime, String>> sortedDiaryEntries = sleepDiary.entries
        .where((entry) =>
    _searchQuery.isEmpty ||
        DateFormat('yyyy-MM-dd').format(entry.key).contains(_searchQuery) ||
        entry.value.contains(_searchQuery))
        .toList();
    sortedDiaryEntries.sort((a, b) => b.key.compareTo(a.key)); // Reverse sort

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              TableCalendar(
                locale: 'ko_KR', // 한국어 설정
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronVisible: true,
                  rightChevronVisible: true,
                  titleTextStyle: TextStyle(color: Colors.black), // 텍스트 색상 검정색
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black), // Chevron 아이콘 색상 검정색
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black), // Chevron 아이콘 색상 검정색
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (sleepDiary.containsKey(date)) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.yellow, // 색상을 노란색으로 변경
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.black, // 텍스트 색상을 검정색으로 변경
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.yellow, // 선택된 날짜 색상을 노란색으로 변경
                    shape: BoxShape.circle,
                    // 크기 조정을 위해 추가할 수 있습니다.
                    border: Border.all(
                      color: Colors.yellow,
                      width: 0.5,
                    ),
                  ),
                  cellMargin: EdgeInsets.all(8.0), // 둥그라미 크기를 줄이기 위해 마진 추가
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _showSleepDiaryDialog(selectedDay);
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SleepDiaryListScreen(
                              email: widget.email,
                              onDiaryDeleted: _loadSleepDiaries,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.list, color: Colors.black), // 아이콘 색상 변경
                      label: Text(
                        '수면 일기 목록',
                        style: TextStyle(color: Colors.black), // 버튼 텍스트 색상 변경
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 버튼 배경색 변경
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list, color: Colors.grey),
                            onPressed: () {
                              // Add filter functionality here if needed
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Scrollbar(
                        child: ListView(
                          padding: EdgeInsets.all(8.0),
                          children: sortedDiaryEntries
                              .map((entry) => ListTile(
                            title: Text(DateFormat('< yyyy-MM-dd >').format(entry.key),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildSurveyStyleEntries(entry.value),
                            ),
                            onTap: () {
                              _showSleepDiaryDialog(entry.key);
                            },
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        email: widget.email,
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
