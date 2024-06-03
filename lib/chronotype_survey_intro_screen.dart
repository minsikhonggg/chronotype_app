import 'package:flutter/material.dart';
import 'chronotype_survey_questions_screen.dart';

class ChronotypeSurveyIntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('크로노타입 설문 소개'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '크로노타입(Chronotype)이란?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChronotypeSurveyQuestionsScreen()),
                      ).then((result) {
                        if (result != null) {
                          Navigator.pop(context, result);
                        }
                      });
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
                        Text('설문 시작', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '크로노타입은 개인의 내부 생체시계 유형을 나타내며, 대부분 24시간의 주기로 일정한 리듬을 유지합니다. '
                        '이 리듬은 수면-각성 주기, 호르몬 분비, 체온 조절 등 우리 몸의 다양한 생리적 과정을 조절합니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '이러한 생체 리듬은 뇌의 시상하부에 위치한 시교차상핵(SCN)에 의해 조절되며, SCN은 외부 빛과 환경적 신호를 수신하여 우리 몸의 생체시계를 리셋합니다. '
                        '이는 교향악단의 지휘자와 같은 역할을 하여 생체 리듬을 안정적으로 유지하도록 돕습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '크로노타입은 유전적 요인, 나이, 생활 습관 등에 따라 다양한 영향을 받으며, 이는 아침형, 저녁형, 중간형으로 분류됩니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '크로노타입에 맞지 않는 활동 패턴을 강제로 따를 경우, 수면 장애, 기분 장애, 대사 질환 등의 건강 문제를 겪을 위험이 증가합니다. '
                        '따라서, 개인의 크로노타입을 정확히 파악하고 이에 맞춰 생활하는 것이 중요하며, 필요에 따라 빛 노출 시간, 운동 시간, 식사 시간을 조절함으로써 크로노타입을 변화시킬 수도 있습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
