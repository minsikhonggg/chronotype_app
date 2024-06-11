import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'profile_screen.dart';
import 'sleep_diary_screen.dart'; // SleepDiaryScreen을 가져옵니다.
import 'data_analysis_screen.dart';
import 'services/data_service.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<DateTime, String> sleepDiary = {};
  int _currentIndex = 0; // Home screen index

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
          title: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
          content: diaryEntry != null
              ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(diaryEntry['diary']),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToSleepDiaryScreen(selectedDate, diaryEntry['diary']);
                    },
                    child: Text('수정'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(selectedDate);
                    },
                    child: Text('삭제'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[200],
                    ),
                  ),
                ],
              ),
            ],
          )
              : Text('작성된 수면 일기가 없습니다.'),
          actions: [
            if (diaryEntry == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSleepDiaryScreen(selectedDate, null);
                },
                child: Text('추가'),
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
                await DataService.deleteSleepDiary(selectedDate, widget.email);
                Navigator.pop(context);
                _showDeletionSuccessDialog();
                _loadSleepDiaries();
              },
              child: Text('삭제'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[200],
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
          content: Text('수면 일기가 삭제되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = HomeScreen(email: widget.email);
        break;
      case 1:
        nextScreen = DataAnalysisScreen(email: widget.email);
        break;
      case 2:
        nextScreen = ProfileScreen(email: widget.email);
        break;
      default:
        nextScreen = HomeScreen(email: widget.email);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlueAccent, Colors.lightGreenAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: DateTime.now(),
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
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
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              _showSleepDiaryDialog(selectedDay);
                            },
                          ),
                          Positioned(
                            top: 20,
                            left: 200,
                            child: GestureDetector(
                              onTap: () => _showHelp(context),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                                child: Icon(
                                  Icons.help,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataAnalysisScreen(email: widget.email),
                            ),
                          );
                        },
                        icon: Icon(Icons.bar_chart),
                        label: Text('수면 일기 목록'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('도움말'),
          content: Text('달력의 날짜를 클릭하여\n수면 일기를 추가하세요.'),
          actions: [
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
}
