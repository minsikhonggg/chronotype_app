import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
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
  List<_SleepData> _filteredSleepData = [];
  int _currentIndex = 1;
  DateTime? _selectedMonth;
  ZoomPanBehavior? _zoomPanBehavior;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now(); // Initialize with the current month
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.xy, // Enable zooming for both x and y axes
    );
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    List<Map<String, dynamic>> diaries = await DataService.getSleepDiaries(widget.email);
    setState(() {
      _sleepData = diaries.map((diary) {
        DateTime date = DateTime.parse(diary['date']);
        String diaryText = diary['diary'];
        List<String> lines = diaryText.split('\n');

        TimeOfDay timeToSleep = _parseTimeOfDay(lines[0]);
        TimeOfDay timeOutOfBed = _parseTimeOfDay(lines[6]);
        TimeOfDay timeToBed = _parseTimeOfDay(lines[1]);
        TimeOfDay timeToLastAwake = _parseTimeOfDay(lines[5]);

        return _SleepData(date, timeToSleep, timeOutOfBed, timeToBed, timeToLastAwake);
      }).toList();

      // Sort the data by date
      _sleepData.sort((a, b) => a.date.compareTo(b.date));

      _filterDataByMonth(_selectedMonth);
      _isLoading = false;
    });
  }

  TimeOfDay _parseTimeOfDay(String line) {
    final time = line.split(': ')[1];
    final timeParts = time.split(' ');
    final timeOfDayParts = timeParts[0].split(':');
    int hour = int.parse(timeOfDayParts[0]);
    int minute = int.parse(timeOfDayParts[1]);
    final period = timeParts[1].toLowerCase();

    return TimeOfDay(hour: hour, minute: minute, period: period);
  }

  double _convertToDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  double _adjustedTime(TimeOfDay time) {
    if (time.period == 'pm') {
      return _convertToDouble(time) + 12;
    } else if (time.period == 'am' && time.hour == 12) {
      return 24; // 12am case
    } else {
      return _convertToDouble(time) + 24;
    }
  }

  void _filterDataByMonth(DateTime? month) {
    if (month == null) {
      setState(() {
        _filteredSleepData = _sleepData;
      });
    } else {
      setState(() {
        _filteredSleepData = _sleepData.where((data) {
          return data.date.year == month.year && data.date.month == month.month;
        }).toList();
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _filterDataByMonth(_selectedMonth);
      });
    }
  }

  String _formatLabel(double value) {
    final intValue = value.round();
    if (intValue == 24) return '00:00';
    return '${intValue % 24}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '수면 데이터 분석',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16), // Add some spacing at the top
          if (_selectedMonth != null)
            Text(
              DateFormat('yyyy. MM').format(_selectedMonth!),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 16), // Add some spacing between the text and the chart
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredSleepData.isNotEmpty
                ? SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('yyyy. MM. dd'),
                intervalType: DateTimeIntervalType.days,
                majorGridLines: MajorGridLines(width: 0),
                interval: 1,
                isVisible: false, // Hide the x-axis
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value}',
                interval: 1,
                minimum: 0,
                maximum: 48,
                majorGridLines: MajorGridLines(width: 0),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  double value = details.value.toDouble();
                  if (value < 24) {
                    return ChartAxisLabel(
                      _formatLabel(value),
                      TextStyle(color: Colors.black),
                    );
                  } else {
                    return ChartAxisLabel(
                      _formatLabel(value - 24),
                      TextStyle(color: Colors.black),
                    );
                  }
                },
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: 24,
                    end: 24,
                    borderColor: Colors.black,
                    borderWidth: 2,
                    dashArray: <double>[5, 5], // Change to dotted line
                    textAngle: 0,
                    horizontalTextAlignment: TextAnchor.middle,
                    verticalTextAlignment: TextAnchor.middle,
                  ),
                ],
              ),
              series: <ChartSeries<_SleepData, DateTime>>[
                RangeAreaSeries<_SleepData, DateTime>(
                  dataSource: _filteredSleepData,
                  xValueMapper: (_SleepData data, _) => data.date,
                  lowValueMapper: (_SleepData data, _) => _adjustedTime(data.timeToSleep),
                  highValueMapper: (_SleepData data, _) => _adjustedTime(data.timeOutOfBed),
                  name: '수면 시작 ~ 최종 기상',
                  color: Colors.red.withOpacity(0.5), // Color for better visualization
                  markerSettings: MarkerSettings(isVisible: true),
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                ),
                RangeAreaSeries<_SleepData, DateTime>(
                  dataSource: _filteredSleepData,
                  xValueMapper: (_SleepData data, _) => data.date,
                  lowValueMapper: (_SleepData data, _) => _adjustedTime(data.timeToBed),
                  highValueMapper: (_SleepData data, _) => _adjustedTime(data.timeToLastAwake),
                  name: '수면 시도 ~ 마지막 깨어남',
                  color: Colors.blue.withOpacity(0.5), // Color for better visualization
                  markerSettings: MarkerSettings(isVisible: true),
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                ),
              ],
              legend: Legend(
                isVisible: true,
                textStyle: TextStyle(fontWeight: FontWeight.bold), // 볼드체 설정
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x', // Tooltip displays only date and label
                header: '',
              ),
              zoomPanBehavior: _zoomPanBehavior,
            )
                : Center(child: Text('해당 월에 두 개 이상의 일기를 작성하세요.')),
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

class _SleepData {
  final DateTime date;
  final TimeOfDay timeToSleep;
  final TimeOfDay timeOutOfBed;
  final TimeOfDay timeToBed;
  final TimeOfDay timeToLastAwake;

  _SleepData(this.date, this.timeToSleep, this.timeOutOfBed, this.timeToBed, this.timeToLastAwake);
}

class TimeOfDay {
  final int hour;
  final int minute;
  final String period;

  TimeOfDay({required this.hour, required this.minute, required this.period});
}
