import 'dart:io';
import 'package:flutter/material.dart';
import 'profile_edit_screen.dart';
import '../services/data_service.dart';
import '../chronotype_survey/chronotype_survey_intro_screen.dart';
import '../chronotype_survey/survey_resultsLog_screen.dart';
import '../bottom_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({required this.email, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? chronotypeResult;
  int? chronotypeScore;
  DateTime? chronotypeDate;
  String? profileImagePath;
  final int _currentIndex = 2;

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
        title: const Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
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
              ),
              const SizedBox(height: 10),
              Text(
                userName ?? 'Loading...',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileEditScreen(email: widget.email),
                      ),
                    );

                    if (result == true) {
                      _loadUserProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: const Text('프로필 수정'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '크로노타입',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        if (chronotypeResult != null)
                          Text(
                            '$chronotypeResult',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent),
                          )
                        else
                          const Text('설문을 시작하세요!',
                              style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChronotypeSurveyIntroScreen(email: widget.email),
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
                  icon: const Icon(Icons.check_box, color: Colors.green),
                  label: const Text('크로노 타입 체크 하기'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurveyResultsLogScreen(
                          email: widget.email,
                          onResultsDeleted: _loadChronotypeResult,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list, color: Colors.black),
                  label: const Text(
                    '설문 조사 결과 목록',
                    style: TextStyle(color: Colors.black), // 버튼 텍스트 색상 변경
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 버튼 배경색 변경
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
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
    );
  }
}
