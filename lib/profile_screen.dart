import 'package:flutter/material.dart';
import 'chronotype_survey_screen.dart';
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
                            MaterialPageRoute(builder: (context) => ChronotypeSurveyScreen()),
                          );
                          setState(() {
                            chronotypeResult = result;
                          });
                        },
                        child: Text('크로노 타입 체크 하기'),
                      ),
                      SizedBox(height: 20),
                      Text(
                        chronotypeResult ?? '설문 조사 결과가 없습니다.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
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
                        child: Text('날짜 선택하여 수면 일기 작성'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SleepAnalysisScreen()),
                          );
                        },
                        child: Text('수면 일기 분석'),
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
