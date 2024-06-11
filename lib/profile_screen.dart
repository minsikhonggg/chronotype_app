import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'profile_edit_screen.dart';
import 'services/data_service.dart';
import 'chronotype_survey_intro_screen.dart';
import 'survey_resultsLog_screen.dart';
import 'bottom_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  ProfileScreen({required this.email});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? chronotypeResult;
  int? chronotypeScore;
  DateTime? chronotypeDate;
  String? profileImagePath;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadChronotypeResult();
  }

  Future<void> _loadUserProfile() async {
    final user = await DataService.getUserByEmail(widget.email);
    if (user != null) {
      setState(() {
        userName = user['name'];
        profileImagePath = user['imagePath'];
      });
    }
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

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? profileImage;
    if (profileImagePath != null) {
      profileImage = profileImagePath!.startsWith('assets')
          ? AssetImage(profileImagePath!) as ImageProvider<Object>
          : FileImage(File(profileImagePath!)) as ImageProvider<Object>;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(email: widget.email),
                ),
              );

              if (result == true) {
                // 사용자가 변경 사항을 저장한 경우 프로필을 다시 로드합니다.
                _loadUserProfile();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  child: profileImage != null
                      ? ClipOval(
                    child: Image(
                      image: profileImage,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userName ?? 'Loading...',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('크로노타입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (chronotypeResult != null)
                        Text(
                          '$chronotypeResult',
                          style: TextStyle(fontSize: 16),
                        )
                      else
                        Text(
                          '설문을 시작하세요!',
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChronotypeSurveyIntroScreen(email: widget.email),
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
                      backgroundColor: Colors.blue[100],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: Text('크로노 타입 체크 하기'),
                  ),
                ],
              ),
            ),
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        email: widget.email,
      ),
    );
  }
}
