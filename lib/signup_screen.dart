import 'package:flutter/material.dart';
import 'services/data_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // 볼드체로 설정, 텍스트 색상 검정색
        ),
        centerTitle: true, // 중앙 정렬
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Username',
                counterText: '', // Hide the counter text
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              maxLength: 30,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email (e.g., example@example.com)',
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
                labelText: 'Password',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm your password',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_confirmPasswordVisible,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_passwordController.text == _confirmPasswordController.text &&
                    _emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  await DataService.saveUser(
                    _nameController.text,
                    _emailController.text,
                    _passwordController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign Up Successful')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and ensure passwords match')));
                }
              },
              child: Text('SIGN UP'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                '이미 계정이 있으신가요? Login',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
