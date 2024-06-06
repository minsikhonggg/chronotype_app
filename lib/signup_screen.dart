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
  bool _isEmailValid = true;
  bool _isPasswordMatch = true;
  bool _isNameNotEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
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
                labelText: 'Full name',
                hintText: 'Enter your full name',
                errorText: _isNameNotEmpty ? null : 'Name cannot be empty',
              ),
              onChanged: (value) {
                setState(() {
                  _isNameNotEmpty = value.trim().isNotEmpty;
                });
              },
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your Email',
                errorText: _isEmailValid ? null : 'Invalid email format',
              ),
              onChanged: (value) {
                setState(() {
                  _isEmailValid = _isValidEmail(value);
                });
              },
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                suffixIcon: Icon(Icons.visibility_off),
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm your password',
                hintText: 'Re-enter your password',
                suffixIcon: Icon(Icons.visibility_off),
                errorText: _isPasswordMatch ? null : 'Passwords do not match',
              ),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _isPasswordMatch = value == _passwordController.text;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isFormValid()
                  ? () async {
                await DataService.saveUser(
                  _nameController.text,
                  _emailController.text,
                  _passwordController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign Up Successful')));
              }
                  : null,
              child: Text('SIGN UP'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                'Already have an account? Login',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _isNameNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
}
