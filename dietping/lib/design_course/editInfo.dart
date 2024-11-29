import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/loaduser.dart';
import '../model/user.dart';
import '../api/api.dart';

class UserEditScreen extends StatefulWidget {
  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nicknameController = TextEditingController();
  TextEditingController kcalController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    User? user = await LoadUser.loadUser();
    final url = Uri.parse(API.loadUser);
    print(user?.user_id);
    try {
      final response = await http.post(
        url,
        body: {
          "userid" : user?.user_id ?? '',
        },
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        if (userInfo['result'] == 'true') {
          setState(() {
            nicknameController.text = userInfo['user_info'][0][0]?.toString() ?? ''; // String 처리
            kcalController.text = userInfo['user_info'][0][1]?.toString() ?? '0';  // double 처리
            heightController.text = userInfo['user_info'][0][2]?.toString() ?? '0.0';  // double 처리
            weightController.text = userInfo['user_info'][0][3]?.toString() ?? '0.0';  // double 처리
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("유저 정보 불러오기 성공")),
          );
        }
      } else {
        throw Exception("Failed to update user information.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit User Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nicknameController,
                decoration: InputDecoration(labelText: "Nickname"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a nickname";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: kcalController,
                decoration: InputDecoration(labelText: "Target Calories"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return "Please enter a valid calorie target";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: heightController,
                decoration: InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return "Please enter a valid height";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return "Please enter a valid weight";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // updateUserInfo();
                  }
                },
                child: Text("Update Information"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
