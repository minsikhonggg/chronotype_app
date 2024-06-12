import 'package:flutter/material.dart';
import 'chronotype_survey_questions_screen.dart';

class ChronotypeSurveyIntroScreen extends StatelessWidget {
  final String email; // 사용자 이메일

  const ChronotypeSurveyIntroScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '크로노타입 설문 소개',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
      ),
      body: PageView(
        children: [
          // 각 페이지 구성
          _buildPage(
            context,
            title: '크로노타입(Chronotype)이란?',
            content: '크로노타입은 개인의 내부 생체시계 유형을 나타내며, 대부분 24시간의 주기로 일정한 리듬을 유지합니다. '
                '이 리듬은 수면-각성 주기, 호르몬 분비, 체온 조절 등 우리 몸의 다양한 생리적 과정을 조절합니다.',
            emoji: '⏰',
          ),
          _buildPage(
            context,
            title: '생체 리듬 조절',
            content: '이러한 생체 리듬은 뇌의 시상하부에 위치한 시교차상핵(SCN)에 의해 조절되며, '
                'SCN은 외부 빛과 환경적 신호를 수신하여 우리 몸의 생체시계를 리셋합니다. '
                '이는 교향악단의 지휘자와 같은 역할을 하여 생체 리듬을 안정적으로 유지하도록 돕습니다.',
            emoji: '🧠🎻',
          ),
          _buildPage(
            context,
            title: '변환하는 크로노타입 유형',
            content: '크로노타입은 유전적 요인, 나이, 생활 습관 등에 따라 다양한 영향을 받으며, 이는 아침형, 저녁형, 중간형으로 분류됩니다.',
            emoji: '🌞🌜',
          ),
          _buildPage(
            context,
            title: '건강 문제와 크로노타입',
            content: '크로노타입에 맞지 않는 활동 패턴을 강제로 따를 경우, '
                '수면 장애, 기분 장애, 대사 질환 등의 건강 문제를 겪을 위험이 증가합니다. ',
            emoji: '⚠️',
          ),
          _buildPage(
            context,
            title: '건강 문제와 크로노타입',
            content: '따라서, 개인의 크로노타입을 정확히 파악하고 이에 맞춰 생활하는 것이 중요하며, '
                '필요에 따라 빛 노출 시간, 운동 시간, 식사 시간을 조절함으로써 크로노타입을 변화시킬 수도 있습니다.',
            emoji: '☀️🏋️🍽️',
          ),
          _buildSurveyStartPage(context), // 설문 시작 페이지
        ],
      ),
    );
  }

  // 각 페이지 구성 함수
  Widget _buildPage(BuildContext context, {required String title, required String content, required String emoji}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 타이틀 텍스트 스타일
            ),
            const SizedBox(height: 20), // 간격
            Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 80), // 이모지 텍스트 스타일
              ),
            ),
            const SizedBox(height: 20), // 간격
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 2.0), // 본문 텍스트 스타일
            ),
          ],
        ),
      ),
    );
  }

  // 설문 시작 페이지 구성 함수
  Widget _buildSurveyStartPage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                '📝',
                style: TextStyle(fontSize: 80), // 이모지 텍스트 스타일
              ),
            ),
            const SizedBox(height: 20), // 간격
            const Text(
              '당신은 아침형, 저녁형, 중간형 중 어디에 속합니까?\n'
                  '각각의 질문에 대해 최근 몇 주 동안 자신이 느낀 바와 가장 일치하는 대답에 체크하세요. '
                  '설문을 마친 다음에는 점수를 합산해서 자신의 크로노타입을 확인합니다.',
              style: TextStyle(fontSize: 16, height: 2.0), // 본문 텍스트 스타일
              textAlign: TextAlign.center, // 텍스트 중앙 정렬
            ),
            const SizedBox(height: 20), // 간격
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChronotypeSurveyQuestionsScreen(email: email), // 설문 질문 화면으로 이동
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 버튼 배경색
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), // 버튼 패딩
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 버튼 모서리 둥글게
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('설문 시작', style: TextStyle(fontSize: 16)), // 버튼 텍스트
                  SizedBox(width: 10), // 간격
                  Icon(Icons.arrow_forward), // 화살표 아이콘
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
