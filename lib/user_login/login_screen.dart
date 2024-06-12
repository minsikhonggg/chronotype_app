import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../services/data_service.dart';
import '../profile/profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  bool _passwordVisible = false; // 비밀번호 가시성 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '로그인', // 앱바 제목
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true, // 제목 중앙 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chrono Tracker', // 로그인 타이틀
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email', // 이메일 라벨
                hintText: 'Enter your Email', // 이메일 힌트 텍스트
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password', // 비밀번호 라벨
                hintText: 'Enter your password', // 비밀번호 힌트 텍스트
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off, // 비밀번호 가시성 아이콘
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible; // 비밀번호 가시성 토글
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible, // 비밀번호 가시성 여부
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;
                final user = await DataService.getUser(email, password); // 데이터 서비스로 사용자 가져오기
                if (user != null) {
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(email: user['email'].toString())), // 프로필 화면으로 이동
                  );
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Failed'))); // 로그인 실패 메시지
                }
              },
              child: const Text('로그인'), // 로그인 버튼 텍스트
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()), // 회원가입 화면으로 이동
                );
              },
              child: const Text(
                "계정이 없으신가요? 회원가입", // 회원가입 안내 텍스트
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
