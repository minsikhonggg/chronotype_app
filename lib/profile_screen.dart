import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  Map<DateTime, List<String>> sleepDiary = {};
  String profileImagePath = 'assets/default_profile.png'; // 기본 이미지 경로

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await DataService.getUserById(widget.userId);
    if (user != null && user['imagePath'] != null) {
      setState(() {
        profileImagePath = user['imagePath'];
      });
    }
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
                      SizedBox(height: 20),
                      TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: DateTime.now(),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SleepDiaryScreen(selectedDate: selectedDate),
                              ),
                            ).then((entry) {
                              if (entry != null) {
                                setState(() {
                                  if (sleepDiary[selectedDate] == null) {
                                    sleepDiary[selectedDate] = [];
                                  }
                                  sleepDiary[selectedDate]!.add(entry);
                                });
                              }
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text('수면 일기 추가'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SleepAnalysisScreen()),
                          );
                        },
                        icon: Icon(Icons.bar_chart),
                        label: Text('수면 일기 분석'),
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
