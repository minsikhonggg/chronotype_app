import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'data_analysis_screen.dart';
import 'profile_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex; // 현재 선택된 탭의 인덱스
  final String email; // 사용자 이메일

  const CustomBottomNavigationBar({Key? key, required this.currentIndex, required this.email}) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  // 탭이 선택되었을 때 호출되는 함수
  void _onTabTapped(int index) {
    // 현재 선택된 탭과 같은 탭을 선택하면 아무것도 하지 않음
    if (index == widget.currentIndex) return;

    // 선택된 탭에 따라 이동할 화면 설정
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

    // 선택된 화면으로 이동 (현재 화면을 대체)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex, // 현재 선택된 탭 인덱스
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.house),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: '수면 분석',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
      selectedItemColor: Colors.blueAccent, // 선택된 아이템 색상
      unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
      showUnselectedLabels: true, // 선택되지 않은 라벨도 표시
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // 선택된 라벨 스타일
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // 선택되지 않은 라벨 스타일
    );
  }
}
