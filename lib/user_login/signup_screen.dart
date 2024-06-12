import 'package:flutter/material.dart';
import '../services/data_service.dart';

// 회원가입 화면 클래스
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

// 회원가입 화면 상태 클래스
class _SignUpScreenState extends State<SignUpScreen> {
  // 텍스트 필드 컨트롤러 선언
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false; // 비밀번호 가시성 여부
  bool _confirmPasswordVisible = false; // 비밀번호 확인 가시성 여부

  // 이메일 유효성 검사 함수
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+', // 이메일 형식 정규표현식
    );
    return emailRegex.hasMatch(email); // 이메일 형식 검사 결과 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체 및 검정색 텍스트
        ),
        centerTitle: true, // 제목 중앙 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 모든 방향으로 16픽셀 패딩
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), // 큰 볼드체 텍스트
            ),
            const SizedBox(height: 20), // 20픽셀 간격
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Username', // 사용자 이름 라벨
                counterText: '', // 카운터 텍스트 숨김
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 기본 테두리 색상 회색
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 포커스된 테두리 색상 회색
                ),
              ),
              maxLength: 30, // 최대 길이 30자
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email', // 이메일 라벨
                hintText: 'Enter your email (e.g., example@example.com)', // 이메일 힌트 텍스트
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 기본 테두리 색상 회색
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 포커스된 테두리 색상 회색
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password', // 비밀번호 라벨
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 기본 테두리 색상 회색
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 포커스된 테두리 색상 회색
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off, // 가시성 아이콘 전환
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible; // 가시성 상태 전환
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible, // 비밀번호 가리기 설정
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm your password', // 비밀번호 확인 라벨
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 기본 테두리 색상 회색
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // 포커스된 테두리 색상 회색
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off, // 가시성 아이콘 전환
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible; // 가시성 상태 전환
                    });
                  },
                ),
              ),
              obscureText: !_confirmPasswordVisible, // 비밀번호 확인 가리기 설정
            ),
            const SizedBox(height: 20), // 20픽셀 간격
            ElevatedButton(
              onPressed: () async {
                // 모든 필드가 채워져 있고, 비밀번호가 일치하며, 이메일 형식이 올바른 경우
                if (_passwordController.text == _confirmPasswordController.text &&
                    _emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _isEmailValid(_emailController.text)) {
                  // 데이터 저장
                  await DataService.saveUser(
                    _nameController.text,
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (mounted) {
                    Navigator.pop(context); // 현재 화면 닫기
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원가입 성공')), // 성공 메시지 표시
                    );
                  }
                } else {
                  // 조건을 충족하지 못한 경우
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('모든 입력을 완료하세요, 패스워드 확인을 해주세요, 이메일 형식을 지키세요')), // 오류 메시지 표시
                    );
                  }
                }
              },
              child: const Text('회원가입'), // 회원가입 버튼 텍스트
            ),
            const SizedBox(height: 20), // 20픽셀 간격
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // 로그인 화면으로 이동
              },
              child: const Text(
                '이미 계정이 있으신가요? Login', // 로그인 화면으로 이동하는 텍스트
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
