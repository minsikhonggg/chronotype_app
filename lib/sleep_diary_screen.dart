import 'package:flutter/material.dart';
import 'services/data_service.dart';

class SleepDiaryScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String email;
  final String? existingDiary;

  SleepDiaryScreen({required this.selectedDate, required this.email, this.existingDiary});

  @override
  _SleepDiaryScreenState createState() => _SleepDiaryScreenState();
}

class _SleepDiaryScreenState extends State<SleepDiaryScreen> {
  TimeOfDay _time1 = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _time2 = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _time3 = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _time5 = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _time6 = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _time7 = TimeOfDay(hour: 7, minute: 0);
  final TextEditingController _controller4 = TextEditingController();
  final TextEditingController _controller9 = TextEditingController();
  final TextEditingController _controller10 = TextEditingController();
  final TextEditingController _controller11 = TextEditingController();

  List<bool> _qualityRatings = List.filled(5, false);

  @override
  void initState() {
    super.initState();
    if (widget.existingDiary != null) {
      _loadExistingDiary(widget.existingDiary!);
    }
  }

  void _loadExistingDiary(String diary) {
    final lines = diary.split('\n');

    setState(() {
      _time1 = _parseTimeOfDay(lines[0]);
      _time2 = _parseTimeOfDay(lines[1]);
      _time3 = _parseDuration(lines[2]);
      _controller4.text = _parseText(lines[3]);
      _time5 = _parseDuration(lines[4]);
      _time6 = _parseTimeOfDay(lines[5]);
      _time7 = _parseTimeOfDay(lines[6]);
      _qualityRatings = _parseQualityRatings(lines[7]);
      _controller9.text = _parseText(lines[8]);
      _controller10.text = _parseText(lines[9]);
      _controller11.text = _parseText(lines[10]);
    });
  }

  TimeOfDay _parseTimeOfDay(String line) {
    final time = line.split(': ')[1];
    final timeParts = time.split(' ');
    final timeOfDayParts = timeParts[0].split(':');
    return TimeOfDay(
      hour: int.parse(timeOfDayParts[0]),
      minute: int.parse(timeOfDayParts[1]),
    );
  }

  TimeOfDay _parseDuration(String line) {
    final duration = line.split(': ')[1];
    final durationParts = duration.split(' ');
    return TimeOfDay(
      hour: int.parse(durationParts[0].replaceAll('시간', '').trim()),
      minute: int.parse(durationParts[1].replaceAll('분', '').trim()),
    );
  }

  String _parseText(String line) {
    return line.split(': ')[1];
  }

  List<bool> _parseQualityRatings(String line) {
    final rating = int.parse(line.split(': ')[1]);
    return List.generate(5, (index) => index + 1 == rating);
  }

  @override
  void dispose() {
    _controller4.dispose();
    _controller9.dispose();
    _controller10.dispose();
    _controller11.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, int timeIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeIndex == 1
          ? _time1
          : timeIndex == 2
          ? _time2
          : timeIndex == 3
          ? _time3
          : timeIndex == 5
          ? _time5
          : timeIndex == 6
          ? _time6
          : _time7,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: timeIndex == 3 || timeIndex == 5),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (timeIndex == 1) {
          _time1 = picked;
        } else if (timeIndex == 2) {
          _time2 = picked;
        } else if (timeIndex == 3) {
          _time3 = picked;
        } else if (timeIndex == 5) {
          _time5 = picked;
        } else if (timeIndex == 6) {
          _time6 = picked;
        } else {
          _time7 = picked;
        }
      });
    }
  }

  void _saveDiary() async {
    String diary = '''
1. 몇 시에 잠자리에 들었습니까?: ${_time1.format(context)}
2. 잠을 자려고 시도한 것은 몇 시부터 입니까?: ${_time2.format(context)}
3. 잠드는 데 시간이 얼마나 걸렸습니까?: ${_time3.hour}시간 ${_time3.minute}분
4. 최종적으로 깨기 전 중간에 몇 번이나 깼습니까?: ${_controller4.text}
5. 중간에 깨어 있던 시간을 모두 합치면 얼마나 됩니까?: ${_time5.hour}시간 ${_time5.minute}분
6. 마지막으로 깬 시간은 몇 시입니까?: ${_time6.format(context)}
7. 마지막으로 깬 후에 침대에서 나온 시간은 몇 시입니까?: ${_time7.format(context)}
8. 자신의 수면의 질을 평가하면?: ${_qualityRatings.indexOf(true) + 1}
9. 꿈을 꾸었습니까? 꾸었다면 어떤 내용이었습니까?: ${_controller9.text}
10. 수면과 관련해서 달리 관찰된 내용이 있다면 적어주세요.: ${_controller10.text}
11. 직장이나 가정에서 겪은 어려운 상황 등 수면에 영향을 미쳤을지도 모른다고 생각되는 사건이 낮에 있었다면 적어주세요.: ${_controller11.text}
''';

    final existingDiary = await DataService.getDiaryByDate(widget.selectedDate, widget.email);
    if (existingDiary != null) {
      await DataService.updateSleepDiary(widget.selectedDate, diary, widget.email);
    } else {
      await DataService.saveSleepDiary(widget.selectedDate, diary, widget.email);
    }
    Navigator.pop(context, widget.selectedDate); // 프로필 화면으로 이동하며 선택한 날짜 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수면 일기 작성 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTimePickerBox('1. 몇 시에 잠자리에 들었습니까?', 1, _time1),
            _buildTimePickerBox('2. 잠을 자려고 시도한 것은 몇 시부터 입니까?', 2, _time2),
            _buildDurationPickerBox('3. 잠드는 데 시간이 얼마나 걸렸습니까?', 3, _time3),
            _buildNumberInputBox('4. 최종적으로 깨기 전 중간에 몇 번이나 깼습니까?', _controller4),
            _buildDurationPickerBox('5. 중간에 깨어 있던 시간을 모두 합치면 얼마나 됩니까?', 5, _time5),
            _buildTimePickerBox('6. 마지막으로 깬 시간은 몇 시입니까?', 6, _time6),
            _buildTimePickerBox('7. 마지막으로 깬 후에 침대에서 나온 시간은 몇 시입니까?', 7, _time7),
            _buildQualityRatingBox('8. 자신의 수면의 질을 평가하면?'),
            _buildTextInputBox('9. 꿈을 꾸었습니까? 꾸었다면 어떤 내용이었습니까?', _controller9),
            _buildTextInputBox('10. 수면과 관련해서 달리 관찰된 내용이 있다면 적어주세요.', _controller10),
            _buildTextInputBox('11. 직장이나 가정에서 겪은 어려운 상황 등 수면에 영향을 미쳤을지도 모른다고 생각되는 사건이 낮에 있었다면 적어주세요.', _controller11),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDiary,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerBox(String label, int timeIndex, TimeOfDay selectedTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Row(
            children: [
              GestureDetector(
                onTap: () => _selectTime(context, timeIndex),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text('${selectedTime.format(context)}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPickerBox(String label, int timeIndex, TimeOfDay selectedTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Row(
            children: [
              GestureDetector(
                onTap: () => _selectTime(context, timeIndex),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text('${selectedTime.hour}시간 ${selectedTime.minute}분'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputBox(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '숫자를 입력하세요'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRatingBox(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Column(
            children: List.generate(5, (index) {
              return Row(
                children: [
                  Checkbox(
                    value: _qualityRatings[index],
                    onChanged: (bool? newValue) {
                      setState(() {
                        _qualityRatings[index] = newValue ?? false;
                        for (int i = 0; i < _qualityRatings.length; i++) {
                          if (i != index) {
                            _qualityRatings[i] = false;
                          }
                        }
                      });
                    },
                  ),
                  Text('${index + 1}. ${(index == 0 ? '아주 나쁘다' : index == 4 ? '아주 좋다' : '보통')}')
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputBox(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: '내용을 입력하세요'),
            maxLines: null,
          ),
        ],
      ),
    );
  }
}
