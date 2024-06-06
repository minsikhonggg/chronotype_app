import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'chronotype_survey_intro_screen.dart';
import 'sleep_diary_screen.dart';
import 'sleep_analysis_screen.dart';
import 'profile_edit_screen.dart';
import 'survey_resultsLog_screen.dart';
import 'dart:io';
import 'services/data_service.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  ProfileScreen({required this.email});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? chronotypeResult;
  int? chronotypeScore;
  DateTime? chronotypeDate;
  Map<DateTime, String> sleepDiary = {};
  String profileImagePath = 'assets/default_profile.png'; // 기본 이미지 경로

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSleepDiaries();
    _loadChronotypeResult();
  }

  Future<void> _loadUserProfile() async {
    final user = await DataService.getUserByEmail(widget.email);
    if (user != null && user['imagePath'] != null) {
      setState(() {
        profileImagePath = user['imagePath'];
      });
    }
  }

  Future<void> _loadSleepDiaries() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries(widget.email);
    setState(() {
      sleepDiary = {
        for (var diary in diaries) DateTime.parse(diary['date']): diary['diary']
      };
    });
  }

  Future<void> _loadChronotypeResult() async {
    final result = await DataService.getLatestChronotypeResult(widget.email);
    if (result != null) {
      setState(() {
        chronotypeResult = result['resultType'];
        chronotypeScore = result['score'];
        chronotypeDate = DateTime.parse(result['date']);
      });
    } else {
      setState(() {
        chronotypeResult = null;
        chronotypeScore = null;
        chronotypeDate = null;
      });
    }
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
                Navigator.pop(context); // 닫기 확인 다이얼로그
                Navigator.pop(context); // 닫기 수면 일기 다이얼로그
                _showDeletionSuccessDialog();
                _loadSleepDiaries(); // 삭제 후 일기 데이터를 다시 로드합니다.
              },
              child: Text('삭제'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[200], // 연한 빨간색
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
                Navigator.pop(context); // 닫기 삭제 완료 다이얼로그
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
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
                    child: Text('수정하기'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(selectedDate);
                    },
                    child: Text('삭제하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[200], // 연한 빨간색
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

  Future<void> _navigateToSleepDiaryScreen(DateTime selectedDate, String? existingDiary) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepDiaryScreen(selectedDate: selectedDate, email: widget.email, existingDiary: existingDiary),
      ),
    );
    _loadSleepDiaries(); // 업데이트된 일기 데이터를 다시 로드합니다.
  }

  void _refreshCalendar() {
    _loadSleepDiaries();
    _loadChronotypeResult();
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
                              builder: (context) => ProfileEditScreen(email: widget.email),
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
                            MaterialPageRoute(
                              builder: (context) => ChronotypeSurveyIntroScreen(email: widget.email), // 이메일 전달
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              chronotypeResult = result['resultType'];
                              chronotypeScore = result['score'];
                              chronotypeDate = DateTime.parse(result['date']);
                            });
                            await DataService.saveChronotypeResult(
                              widget.email,
                              result['resultType'],
                              result['score'],
                              result['date'],
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100], // primary 대신 backgroundColor 사용
                          foregroundColor: Colors.black, // onPrimary 대신 foregroundColor 사용
                        ),
                        child: Text('크로노 타입 체크 하기'),
                      ),
                      SizedBox(height: 20),
                      if (chronotypeResult != null)
                        Column(
                          children: [
                            Text(
                              '최근 설문 결과',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '결과: $chronotypeResult',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '점수: $chronotypeScore',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '날짜: ${DateFormat('yyyy-MM-dd').format(chronotypeDate!)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      else
                        Text(
                          '설문 조사 결과가 없습니다.',
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
                              builder: (context) => SleepAnalysisScreen(onDiaryDeleted: _refreshCalendar, email: widget.email),
                            ),
                          );
                        },
                        icon: Icon(Icons.bar_chart),
                        label: Text('수면 일기 목록'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurveyResultsScreen(
                                email: widget.email,
                                onResultsDeleted: _loadChronotypeResult,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.list),
                        label: Text('설문 조사 결과 관리'),
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
