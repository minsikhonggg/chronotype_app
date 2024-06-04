import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'chronotype_survey_intro_screen.dart';
import 'sleep_diary_screen.dart';
import 'sleep_analysis_screen.dart';
import 'profile_edit_screen.dart';
import 'dart:io';
import 'services/data_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? chronotypeResult;
  Map<DateTime, String> sleepDiary = {};
  String profileImagePath = 'assets/default_profile.png'; // 기본 이미지 경로

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSleepDiaries();
  }

  Future<void> _loadUserProfile() async {
    final user = await DataService.getUserById(widget.userId);
    if (user != null && user['imagePath'] != null) {
      setState(() {
        profileImagePath = user['imagePath'];
      });
    }
  }

  Future<void> _loadSleepDiaries() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries();
    setState(() {
      sleepDiary = {
        for (var diary in diaries) DateTime.parse(diary['date']): diary['diary']
      };
    });
  }

  Future<void> _showSleepDiaryDialog(DateTime selectedDate) async {
    final diaryEntry = await DataService.getDiaryByDate(selectedDate);

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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSleepDiaryScreen(selectedDate);
                },
                child: Text('수정하기'),
              ),
            ],
          )
              : Text('작성된 수면 일기가 없습니다.'),
          actions: [
            if (diaryEntry == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToSleepDiaryScreen(selectedDate);
                },
                child: Text('추가하기'),
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

  Future<void> _navigateToSleepDiaryScreen(DateTime selectedDate) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepDiaryScreen(selectedDate: selectedDate),
      ),
    );
    _loadSleepDiaries(); // 업데이트된 일기 데이터를 다시 로드합니다.
  }

  void _refreshCalendar() {
    _loadSleepDiaries();
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('도움말'),
          content: Text('달력의 날짜를 클릭하여 수면 일기를 추가하거나 수정할 수 있습니다. 빨간 점이 있는 날짜는 수면 일기가 작성된 날짜입니다.'),
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

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> profileImage = profileImagePath.startsWith('assets')
        ? AssetImage(profileImagePath) as ImageProvider<Object>
        : FileImage(File(profileImagePath)) as ImageProvider<Object>;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거
            flexibleSpace: FlexibleSpaceBar(
              title: Text('프로필'),
              background: Image.asset('assets/profile_background.jpeg', fit: BoxFit.cover),
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
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImage,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final updatedImagePath = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileEditScreen(userId: widget.userId),
                            ),
                          );
                          if (updatedImagePath != null) {
                            setState(() {
                              profileImagePath = updatedImagePath;
                            });
                          }
                        },
                        child: Text('Edit Profile'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChronotypeSurveyIntroScreen()),
                          );
                          if (result != null) {
                            setState(() {
                              chronotypeResult = result;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100], // primary 대신 backgroundColor 사용
                          foregroundColor: Colors.black, // onPrimary 대신 foregroundColor 사용
                        ),
                        child: Text('크로노 타입 체크 하기'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        chronotypeResult ?? '설문 조사 결과가 없습니다.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Stack(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: DateTime.now(),
                            calendarFormat: CalendarFormat.month, // 기본 달력 형식 설정
                            availableCalendarFormats: const {CalendarFormat.month: 'Month'}, // 달력 형식 선택 버튼 제거
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
                              builder: (context) => SleepAnalysisScreen(onDiaryDeleted: _refreshCalendar),
                            ),
                          );
                        },
                        icon: Icon(Icons.bar_chart),
                        label: Text('수면 일기 목록'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
