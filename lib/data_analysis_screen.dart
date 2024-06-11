import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'services/data_service.dart';
import 'bottom_navigation_bar.dart';

class DataAnalysisScreen extends StatefulWidget {
  final String email;

  DataAnalysisScreen({required this.email});

  @override
  _DataAnalysisScreenState createState() => _DataAnalysisScreenState();
}

class _DataAnalysisScreenState extends State<DataAnalysisScreen> {
  List<_SleepData> _sleepData = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries(widget.email);
    setState(() {
      _sleepData = diaries.map((diary) {
        DateTime date = DateTime.parse(diary['date']);
        String diaryText = diary['diary'];
        List<String> lines = diaryText.split('\n');

        TimeOfDay timeToBed = _parseTimeOfDay(lines[0]);
        TimeOfDay timeOutOfBed = _parseTimeOfDay(lines[6]);

        return _SleepData(date, timeToBed, timeOutOfBed);
      }).toList();
    });
  }

  TimeOfDay _parseTimeOfDay(String line) {
    final time = line.split(': ')[1];
    final timeParts = time.split(' ');
    final timeOfDayParts = timeParts[0].split(':');
    int hour = int.parse(timeOfDayParts[0]);
    int minute = int.parse(timeOfDayParts[1]);
    final period = timeParts[1].toLowerCase();

    if (period == 'pm' && hour != 12) {
      hour += 12;
    } else if (period == 'am' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Analysis'),
      ),
      body: _sleepData.isNotEmpty
          ? SfCartesianChart(
        primaryXAxis: DateTimeAxis(),
        primaryYAxis: NumericAxis(
          labelFormat: '{value}:00',
          interval: 1,
          minimum: 0,
          maximum: 24,
        ),
        series: <ChartSeries<_SleepData, DateTime>>[
          LineSeries<_SleepData, DateTime>(
            dataSource: _sleepData,
            xValueMapper: (_SleepData data, _) => data.date,
            yValueMapper: (_SleepData data, _) => data.timeToBed.hour + data.timeToBed.minute / 60,
            name: 'Time to Bed',
            color: Colors.blue,
            markerSettings: MarkerSettings(isVisible: true),
          ),
          LineSeries<_SleepData, DateTime>(
            dataSource: _sleepData,
            xValueMapper: (_SleepData data, _) => data.date,
            yValueMapper: (_SleepData data, _) => data.timeOutOfBed.hour + data.timeOutOfBed.minute / 60,
            name: 'Time out of Bed',
            color: Colors.red,
            markerSettings: MarkerSettings(isVisible: true),
          ),
        ],
        legend: Legend(isVisible: true),
        tooltipBehavior: TooltipBehavior(enable: true),
      )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        email: widget.email,
      ),
    );
  }
}

class _SleepData {
  final DateTime date;
  final TimeOfDay timeToBed;
  final TimeOfDay timeOutOfBed;

  _SleepData(this.date, this.timeToBed, this.timeOutOfBed);
}
