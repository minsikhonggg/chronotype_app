import 'package:flutter/material.dart';
import 'profile_screen.dart';

class ChronotypeSurveyResultScreen extends StatelessWidget {
  final int totalScore;
  final String resultType;
  final String date; // 날짜 필드 추가
  final String email; // 이메일 필드 추가

  const ChronotypeSurveyResultScreen({
    Key? key,
    required this.totalScore,
    required this.resultType,
    required this.date, // 생성자에 날짜 필드 추가
    required this.email, // 생성자에 이메일 필드 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '크로노타입 설문 결과',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
              children: [
                const Text(
                  '총 점수', // 총 점수 텍스트
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 2.0),
                ),
                const SizedBox(height: 10),
                Text(
                  '$totalScore점', // 총 점수 표시
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red, height: 2.0),
                ),
                const SizedBox(height: 20),
                const Text(
                  '16 ~ 30 점: 확실한 저녁형\n'
                      '31 ~ 41 점: 온건한 저녁형\n'
                      '42 ~ 58 점: 중간형\n'
                      '59 ~ 69 점: 온건한 아침형\n'
                      '70 ~ 86 점: 확실한 아침형', // 점수에 따른 유형 설명
                  style: TextStyle(fontSize: 18, height: 2.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // 간격
                Text(
                  resultType, // 결과 유형 표시
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red, height: 2.0),
                ),
                const SizedBox(height: 40), // 간격
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst); // 모든 화면을 닫고 첫 화면으로 돌아감
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(email: email), // 프로필 화면으로 이동
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                    children: const [
                      Text('결과 확인'),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward), // 버튼 아이콘
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
