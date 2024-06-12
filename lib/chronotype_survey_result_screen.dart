import 'package:flutter/material.dart';
import 'profile_screen.dart'; // ProfileScreen을 import합니다.

class ChronotypeSurveyResultScreen extends StatelessWidget {
  final int totalScore;
  final String resultType;
  final String date; // 날짜 필드 추가
  final String email; // 이메일 필드 추가

  ChronotypeSurveyResultScreen({
    required this.totalScore,
    required this.resultType,
    required this.date, // 생성자에 날짜 필드 추가
    required this.email, // 생성자에 이메일 필드 추가
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('크로노타입 설문 결과',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '총 점수',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 2.0),
                ),
                SizedBox(height: 10),
                Text(
                  '$totalScore점',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red, height: 2.0),
                ),
                SizedBox(height: 20),
                Text(
                  '16 ~ 30 점: 확실한 저녁형\n'
                      '31 ~ 41 점: 온건한 저녁형\n'
                      '42 ~ 58 점: 중간형\n'
                      '59 ~ 69 점: 온건한 아침형\n'
                      '70 ~ 86 점: 확실한 아침형',
                  style: TextStyle(fontSize: 18, height: 2.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '$resultType',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red, height: 2.0),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(email: email),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('결과 확인'),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward),
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
