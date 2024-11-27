import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api.dart';
import '../cubit/auth_cubit.dart';
import '../home_screen.dart';
import '../main.dart';
import '../model/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_theme.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import 'login.dart';
import '../fitness_app/fitness_app_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userIdController = TextEditingController(text: '');
  final TextEditingController userNameController = TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController passwordController = TextEditingController(text: '');
  final TextEditingController nicknameController = TextEditingController(text: '');
  final TextEditingController ageController = TextEditingController(text: '');
  //final TextEditingController genderController = TextEditingController(text: '');
  final TextEditingController kcalController = TextEditingController(text: '');
  final TextEditingController heightController = TextEditingController(text: '');
  final TextEditingController weightController = TextEditingController(text: '');

  String? selectedGender;
  bool passwordVisible = false;
  bool isChecked = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  checkUserId() async {
    try {
      var response = await http.post(
          Uri.parse(API.validateId),
          body: {
            'id': userIdController.text.trim()
          }
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['createId'] == "false") {
          Fluttertoast.showToast(
            msg: 'Id is already in use. Please try another id',
          );
        } else {
          // 나이를 여기에서 처리
          var ageInput = ageController.text.trim();
          int age;

          var kcalInput = kcalController.text.trim();
          var heightInput = heightController.text.trim();
          var weightInput = weightController.text.trim();
          double kcal = double.parse(kcalInput);
          double height = double.parse(heightInput);
          double weight = double.parse(weightInput);

          // 나이 입력 값이 비어있지 않고 숫자인지 체크
          if (ageInput.isNotEmpty) {
            // 정규 표현식을 사용하여 숫자인지 확인
            if (RegExp(r'^[0-9]+$').hasMatch(ageInput)) {
              age = int.parse(ageInput); // 숫자로 변환
            } else {
              Fluttertoast.showToast(
                msg: 'Please enter a valid age',
              );
              return; // 유효하지 않으면 함수 종료
            }
          } else {
            // 나이가 입력되지 않은 경우 기본값 설정
            age = 0; // 혹은 원하는 기본값 설정
          }

          context.read<AuthCubit>().signUp(
              id: userIdController.text.trim (),
              name: userNameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
              nickname: nicknameController.text.trim(),
              age: age ?? 0,
              gender: selectedGender ?? "",
              kcal : kcal,
              height: height,
              weight: weight
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register new\naccount',
                      style: heading2.copyWith(color: textBlack),
                    ),
                    SizedBox(height: 20),
                    Image.asset('assets/images/accent.png', width: 99, height: 4),
                  ],
                ),
                SizedBox(height: 48),
                Form(
                  child: Column(
                    children: [
                      InputField(
                        hintText: 'ID',
                        controller: userIdController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: '이름',
                        controller: userNameController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: 'Email',
                        controller: emailController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: 'Password',
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        suffixIcon: IconButton(
                          color: textGrey,
                          splashRadius: 1,
                          icon: Icon(passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: togglePassword,
                        ),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: '닉네임',
                        controller: nicknameController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: '나이',
                        controller: ageController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      // 성별 선택 드롭다운 메뉴
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        items: [
                          DropdownMenuItem(
                            value: "남자",
                            child: Text("남자"),
                          ),
                          DropdownMenuItem(
                            value: "여자",
                            child: Text("여자"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "성별을 선택하세요",
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: '목표 칼로리',
                        controller: kcalController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: '키',
                        controller: heightController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                      InputField(
                        hintText: '몸무게',
                        controller: weightController,
                        suffixIcon: SizedBox(),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
                SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isChecked ? primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.0),
                          border: isChecked
                              ? null
                              : Border.all(color: textGrey, width: 1.5),
                        ),
                        width: 20,
                        height: 20,
                        child: isChecked
                            ? Icon(Icons.check, size: 20, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By creating an account, you agree to our',
                          style: regular16pt.copyWith(color: textGrey),
                        ),
                        Text(
                          'Terms & Conditions',
                          style: regular16pt.copyWith(color: primaryBlue),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 32),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                              (route) => false);
                    } else if (state is AuthFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade700,
                          content: Text(state.error),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return CustomPrimaryButton(
                      buttonColor: primaryBlue,
                      textValue: 'Register',
                      textColor: Colors.white,
                      onPressed: () {
                        if (isChecked) {
                          checkUserId(); // validateId 호출
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content: Text(
                                'Are you agree with our Terms & Conditions?',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: regular16pt.copyWith(color: textGrey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        'Login',
                        style: regular16pt.copyWith(color: primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
