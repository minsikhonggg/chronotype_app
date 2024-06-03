import 'package:flutter/material.dart';

class ChronotypeSurveyQuestionsScreen extends StatefulWidget {
  @override
  _ChronotypeSurveyQuestionsScreenState createState() => _ChronotypeSurveyQuestionsScreenState();
}

class _ChronotypeSurveyQuestionsScreenState extends State<ChronotypeSurveyQuestionsScreen> {
  PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  int _totalScore = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '하루 일정을 마음대로 잡을 수 있다면 대략 몇 시 정도에 일어나시겠습니까?',
      'options': [
        {'text': '오전 5:00 ~ 6:30', 'score': 5},
        {'text': '오전 6:30 ~ 7:45', 'score': 4},
        {'text': '오전 7:45 ~ 9:45', 'score': 3},
        {'text': '오전 9:45 ~ 11:00', 'score': 2},
        {'text': '오전 11:00 ~ 12:00', 'score': 1},
      ]
    },
    {
      'question': '저녁 일정을 마음대로 잡을 수 있다면 대략 몇 시 정도에 잠자리에 드시겠습니까?',
      'options': [
        {'text': '오후 8:00 ~ 9:00', 'score': 5},
        {'text': '오후 9:30 ~ 10:15', 'score': 4},
        {'text': '오후 10:15 ~ 오전 12:30', 'score': 3},
        {'text': '오전 12:30 ~ 1:45', 'score': 2},
        {'text': '오전 1:45 ~ 3:00', 'score': 1},
      ]
    },
    {
      'question': '아침에 특정 시간에 일어나야 하는 경우 알람시계에 얼마나 의존하는 편입니까?',
      'options': [
        {'text': '전혀 의존하지 않는다', 'score': 4},
        {'text': '살짝 의존한다', 'score': 3},
        {'text': '어느 정도 의존한다', 'score': 2},
        {'text': '아주 많이 의존한다', 'score': 1},
      ]
    },
    {
      'question': '아침에 일어나기가 얼마나 쉽습니까? (뜻하지 않았던 시간에 깬 것이 아닐 때)',
      'options': [
        {'text': '아주 쉽다', 'score': 4},
        {'text': '꽤 쉽다', 'score': 3},
        {'text': '조금 어렵다', 'score': 2},
        {'text': '아주 어렵다', 'score': 1},
      ]
    },
    {
      'question': '아침에 일어난 후 30분 정도 동안 머리가 얼마나 잘 돌아갑니까?',
      'options': [
        {'text': '아주 잘 돌아간다', 'score': 4},
        {'text': '꽤 잘 돌아간다', 'score': 3},
        {'text': '살짝 잘 돌아간다', 'score': 2},
        {'text': '전혀 잘 돌아가지 않는다', 'score': 1},
      ]
    },
    {
      'question': '깨어나서 첫 30분 동안 얼마나 배고픔을 느낍니까?',
      'options': [
        {'text': '아주 배고프다', 'score': 4},
        {'text': '꽤 배고프다', 'score': 3},
        {'text': '살짝 배고프다', 'score': 2},
        {'text': '전혀 배고프지 않다', 'score': 1},
      ]
    },
    {
      'question': '아침에 깨어나서 첫 30분 동안에 기분이 어떻습니까?',
      'options': [
        {'text': '아주 상쾌하다', 'score': 4},
        {'text': '꽤 상쾌하다', 'score': 3},
        {'text': '꽤 피곤하다', 'score': 2},
        {'text': '아주 피곤하다', 'score': 1},
      ]
    },
    {
      'question': '내일이 휴일이라면 평소와 비교했을 때 오늘은 몇 시에 잠자리에 들겠습니까?',
      'options': [
        {'text': '평소대로 혹은 살짝 늦게', 'score': 4},
        {'text': '1시간 미만으로 늦게', 'score': 3},
        {'text': '1~2시간 늦게', 'score': 2},
        {'text': '2시간 이상 늦게', 'score': 1},
      ]
    },
    {
      'question': '당신은 운동을 하기로 마음먹었습니다. 한 친구가 당신에게 일주일에 두 번, 한 시간씩 운동하라며, 자기에게 제일 좋은 운동시간은 아침 7~8시 사이라고 했습니다. 다른 것은 제외하고 자신의 내부 생체시계만을 고려할 때 당신은 이런 일정으로 얼마나 잘할 수 있을 것 같습니까?',
      'options': [
        {'text': '아주 잘할 것이다', 'score': 4},
        {'text': '그럭저럭 잘할 것이다', 'score': 3},
        {'text': '어려울 것이다', 'score': 2},
        {'text': '아주 어려울 것이다', 'score': 1},
      ]
    },
    {
      'question': '저녁에 대략 몇 시쯤이면 피곤해져 잠을 자야겠다는 생각이 듭니까?',
      'options': [
        {'text': '오후 8:00 ~ 9:00', 'score': 5},
        {'text': '오후 9:00 ~ 10:15', 'score': 4},
        {'text': '오후 10:15 ~ 오전 12:30', 'score': 3},
        {'text': '오전 12:30 ~ 2:00', 'score': 2},
        {'text': '오전 2:00 ~ 3:00', 'score': 1},
      ]
    },
    {
      'question': '두 시간 동안 치러야 할 중요한 시험에서 자신의 능력을 최대로 발휘하고 싶습니다. 그날의 시험 일정은 당신 마음대로 정할 수 있습니다. 자신의 내부 생체시계만을 고려할 때 다음 중 언제를 선택하시겠습니까?',
      'options': [
        {'text': '오전 8:00 ~ 10:00', 'score': 6},
        {'text': '오전 11:00 ~ 오후 1:00', 'score': 4},
        {'text': '오후 3:00 ~ 5:00', 'score': 2},
        {'text': '오후 7:00 ~ 9:00', 'score': 0},
      ]
    },
    {
      'question': '밤 11시에 잠자리에 들었다면 얼마나 피곤할까요?',
      'options': [
        {'text': '아주 피곤하다', 'score': 5},
        {'text': '꽤 피곤하다', 'score': 3},
        {'text': '조금 피곤하다', 'score': 2},
        {'text': '전혀 피곤하지 않다', 'score': 0},
      ]
    },
    {
      'question': '어떤 이유가 있어서 평소보다 몇 시간 늦게 잠자리에 들었지만 다음 날 아침에는 정해진 시간에 일어날 필요가 없습니다. 그럼 다음 중 어떻게 행동할 것 같습니까?',
      'options': [
        {'text': '평소 시간에 일어나겠지만 다시 잠들지 않는다', 'score': 4},
        {'text': '평소 시간에 일어나서 그 후로 존다', 'score': 3},
        {'text': '평소 시간에 일어나겠지만 다시 잠든다', 'score': 2},
        {'text': '평소보다 늦은 시간에 일어난다', 'score': 1},
      ]
    },
    {
      'question': '당신은 야간 경계 근무를 서기 위해 오전 4시부터 6시까지 깨어 있어야 합니다. 다음 날에는 해야 할 일이 따로 없습니다. 그럼 당신은 다음 중 어떻게 행동하시겠습니까?',
      'options': [
        {'text': '경계 근무 전에만 잔다', 'score': 4},
        {'text': '경계 근무 전후로 푹 잔다', 'score': 3},
        {'text': '경계 근무 전후로 잠깐씩 잔다', 'score': 2},
        {'text': '경계 근무를 마칠 때까지 아예 자지 않는다', 'score': 1},
      ]
    },
    {
      'question': '두 시간 동안 고된 육체노동을 해야 합니다. 하루의 일정은 당신 마음대로 잡을 수 있습니다. 자신의 내부 생체시계만을 고려할 때 다음 일정 중 언제를 선택하시겠습니까?',
      'options': [
        {'text': '오전 8:00 ~ 10:00', 'score': 4},
        {'text': '오전 11:00 ~ 오후 1:00', 'score': 3},
        {'text': '오후 3:00 ~ 5:00', 'score': 2},
        {'text': '오후 7:00 ~ 9:00', 'score': 1},
      ]
    },
    {
      'question': '당신은 운동을 하기로 마음먹었습니다. 한 친구가 당신에게 일주일에 두 번, 한 시간씩 운동하라며, 자기에게 제일 좋은 운동시간은 오후 10~11시 사이라고 했습니다. 다른 것은 제외하고 자신의 내부 생체시계만을 고려할 때 당신은 이런 일정으로 얼마나 잘할 수 있을 것 같습니까?',
      'options': [
        {'text': '아주 어려울 것이다', 'score': 4},
        {'text': '어려울 것이다', 'score': 3},
        {'text': '그럭저럭 잘할 것이다', 'score': 2},
        {'text': '아주 잘할 것이다', 'score': 1},
      ]
    },
    {
      'question': '일하는 시간을 마음대로 선택할 수 있다고 해봅시다. 휴식시간을 포함해서 하루에 다섯 시간 일하고, 당신이 하는 일은 재미있고, 일을 하는 만큼 성과급을 받는다고 가정해봅시다. 그럼 대략 몇 시부터 일을 시작하시겠습니까?',
      'options': [
        {'text': '오전 4:00 ~ 8:00에 시작해서 5시간 동안', 'score': 5},
        {'text': '오전 8:00 ~ 9:00에 시작해서 5시간 동안', 'score': 4},
        {'text': '오전 9:00 ~ 오후 2:00에 시작해서 5시간 동안', 'score': 3},
        {'text': '오후 2:00 ~ 5:00에 시작해서 5시간 동안', 'score': 2},
        {'text': '오후 5:00 ~ 오전 4:00에 시작해서 5시간 동안', 'score': 1},
      ]
    },
    {
      'question': '보통 하루 중 몇 시에 기분이 제일 좋습니까?',
      'options': [
        {'text': '오전 5:00 ~ 8:00', 'score': 5},
        {'text': '오전 8:00 ~ 10:00', 'score': 4},
        {'text': '오전 10:00 ~ 오후 5:00', 'score': 3},
        {'text': '오후 5:00 ~ 10:00', 'score': 2},
        {'text': '오후 10:00 ~ 오전 5:00', 'score': 1},
      ]
    },
    {
      'question': '아침형 인간과 저녁형 인간이라는 말이 있습니다. 당신은 어느 쪽에 속한다고 생각하십니까?',
      'options': [
        {'text': '확실히 아침형', 'score': 6},
        {'text': '저녁형보다는 아침형인 듯', 'score': 4},
        {'text': '아침형보다는 저녁형인 듯', 'score': 2},
        {'text': '확실히 저녁형', 'score': 1},
      ]
    },
  ];

  void _nextQuestion(int score) {
    setState(() {
      _totalScore += score;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        _showResult();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showResult() {
    String resultType;
    if (_totalScore >= 16 && _totalScore <= 30) {
      resultType = '확실한 저녁형';
    } else if (_totalScore >= 31 && _totalScore <= 41) {
      resultType = '온건한 저녁형';
    } else if (_totalScore >= 42 && _totalScore <= 58) {
      resultType = '중간형';
    } else if (_totalScore >= 59 && _totalScore <= 69) {
      resultType = '온건한 아침형';
    } else {
      resultType = '확실한 아침형';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChronotypeSurveyResultScreen(totalScore: _totalScore, resultType: resultType),
      ),
    ).then((result) {
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('크로노타입 설문'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _previousQuestion,
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // 사용자가 직접 스크롤하지 못하게 설정
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1} / ${_questions.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  '${index + 1}. ${question['question']}', // 인덱스를 이용하여 질문 번호 추가
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Column(
                  children: question['options'].map<Widget>((option) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: () => _nextQuestion(option['score']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(option['text'], textAlign: TextAlign.left)),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChronotypeSurveyResultScreen extends StatelessWidget {
  final int totalScore;
  final String resultType;

  ChronotypeSurveyResultScreen({required this.totalScore, required this.resultType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('크로노타입 설문 결과'),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$totalScore점',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                SizedBox(height: 20),
                Text(
                  '16 ~ 30 점: 확실한 저녁형\n'
                      '31 ~ 41 점: 온건한 저녁형\n'
                      '42 ~ 58 점: 중간형\n'
                      '59 ~ 69 점: 온건한 아침형\n'
                      '70 ~ 86 점: 확실한 아침형',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '$resultType',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, resultType);
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
