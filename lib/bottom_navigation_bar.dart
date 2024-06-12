import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'data_analysis_screen.dart';
import 'profile_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final String email;

  CustomBottomNavigationBar({required this.currentIndex, required this.email});

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  void _onTabTapped(int index) {
    if (index == widget.currentIndex) return;

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
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onTabTapped,
      items: [
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
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
