import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/data_service.dart';
import 'profile_screen.dart'; // 프로필 페이지 import

class ProfileEditScreen extends StatefulWidget {
  final String email;

  ProfileEditScreen({required this.email});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await DataService.getUserByEmail(widget.email);
    if (user != null) {
      setState(() {
        _nameController.text = user['name'];
        _phoneController.text = user['phone'] ?? '';
        _passwordController.text = user['password'];
        _imagePath = user['imagePath'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: _imagePath != null
                    ? ClipOval(
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('사진 변경'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: TextEditingController(text: widget.email),
              decoration: InputDecoration(labelText: 'Email'),
              enabled: false, // 이메일은 수정 불가
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await DataService.updateUser(
                  widget.email,
                  _nameController.text,
                  _phoneController.text,
                  _passwordController.text,
                  _imagePath,
                );
                Navigator.pop(context, true); // pop으로 수정
              },
              child: Text('적용'),
            ),
          ],
        ),
      ),
    );
  }
}
