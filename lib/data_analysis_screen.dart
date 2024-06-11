import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/data_service.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'home.dart';
import 'profile_screen.dart';

class DataAnalysisScreen extends StatefulWidget {
  final String email;

  DataAnalysisScreen({required this.email});

  @override
  _DataAnalysisScreenState createState() => _DataAnalysisScreenState();
}

class _DataAnalysisScreenState extends State<DataAnalysisScreen> {
  List<FlSpot> _bedtimeSpots = [];
  List<FlSpot> _attemptSleepSpots = [];
  List<FlSpot> _wakeTimeSpots = [];
  List<FlSpot> _outOfBedTimeSpots = [];
  int _currentIndex = 1; // Analysis screen index

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    final diaries = await DataService.getSleepDiaries(widget.email);
    setState(() {
      _bedtimeSpots = _extractSpots(diaries, 1);
      _attemptSleepSpots = _extractSpots(diaries, 2);
      _wakeTimeSpots = _extractSpots(diaries, 6);
      _outOfBedTimeSpots = _extractSpots(diaries, 7);
    });
  }

  List<FlSpot> _extractSpots(List<Map<String, dynamic>> diaries, int timeIndex) {
    List<FlSpot> spots = [];
    for (var diary in diaries) {
      DateTime date = DateTime.parse(diary['date']);
      String entry = diary['diary'].split('\n')[timeIndex];
      TimeOfDay time = _parseTimeOfDay(entry);
      spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), time.hour + time.minute / 60.0));
    }
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
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

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = HomeScreen(email: widget.email);
        break;
      case 1:
        nextScreen = DataAnalysisScreen(email: widget.email);
        break;
      case 2:
        nextScreen = ProfileScreen(email: widget.email);
        break;
      default:
        nextScreen = HomeScreen(email: widget.email);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Data Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: _bedtimeSpots.isNotEmpty ? _bedtimeSpots.first.x : 0,
            maxX: _bedtimeSpots.isNotEmpty ? _bedtimeSpots.last.x : 1,
            minY: 0,
            maxY: 24,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 4,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}:00');
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(DateFormat('MM/dd').format(date));
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: _bedtimeSpots,
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                dotData: FlDotData(show: false),
              ),
              LineChartBarData(
                spots: _attemptSleepSpots,
                isCurved: true,
                barWidth: 2,
                color: Colors.red,
                dotData: FlDotData(show: false),
              ),
              LineChartBarData(
                spots: _wakeTimeSpots,
                isCurved: true,
                barWidth: 2,
                color: Colors.green,
                dotData: FlDotData(show: false),
              ),
              LineChartBarData(
                spots: _outOfBedTimeSpots,
                isCurved: true,
                barWidth: 2,
                color: Colors.orange,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
