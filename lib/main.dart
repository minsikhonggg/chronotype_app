import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'data_analysis_screen.dart';
import 'splash_screen.dart';
import 'services/data_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // 이 라인을 추가합니다.
  await DataService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronotype App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: const Color(0xFF000000),
          secondary: const Color(0xFF0D47A1),
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          ),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(email: 'example@example.com'),
        '/profile': (context) => ProfileScreen(email: 'example@example.com'),
        '/analysis': (context) => DataAnalysisScreen(email: 'example@example.com'),
      },
    );
  }
}