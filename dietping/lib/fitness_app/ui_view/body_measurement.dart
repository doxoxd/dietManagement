// 신체 정보 보여주는 부분
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:flutter/material.dart';

import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../model/loaduser.dart';
import '../../model/user.dart';

class BodyMeasurementView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const BodyMeasurementView({Key? key, this.animationController, this.animation})
      : super(key: key);

  @override
  _BodyMeasurementViewState createState() => _BodyMeasurementViewState();
}

class _BodyMeasurementViewState extends State<BodyMeasurementView> {
  String? userId;
  int? userAge;
  String? userGender;
  double? userHeight;
  double? userWeight;
  double? bmi = 0;
  double? bmr = 0;

  String bmiResult = ""; // BMI 결과를 저장할 변수

  @override
  void initState() {
    super.initState();
    loadUserBodyInfo(); // 사용자 데이터를 로드
  }

  // 사용자 데이터를 로드하고 BMI와 BMR 계산
  void loadUserBodyInfo() async {
    User? user = await LoadUser.loadUser();
    if (user == null) {
      Fluttertoast.showToast(msg: '사용자 정보를 불러올 수 없습니다.');
      return;
    }

    setState(() {
      userId = user.user_id;
      userAge = user.user_age;
      userGender = user.user_gender;
      userHeight = user.user_height;
      userWeight = user.user_weight;

      // BMI 계산
      if (userHeight != null && userWeight != null) {
        final heightInMeters = userHeight! / 100; // 키를 m 단위로 변환
        bmi = userWeight! / (heightInMeters * heightInMeters);
        bmiResult = getBmiResult(bmi!); // BMI에 따른 결과 텍스트 설정
      }

      // BMR 계산
      if (userAge != null && userWeight != null && userHeight != null && userGender != null) {
        if (userGender == '남자') {
          bmr = 66.47 + (13.75 * userWeight!) + (5 * userHeight!) - (6.76 * userAge!);
        } else if (userGender == '여자') {
          bmr = 655.1 + (9.56 * userWeight!) + (1.85 * userHeight!) - (4.68 * userAge!);
        }
      }
    });
  }

  // BMI에 따른 결과 반환
  String getBmiResult(double bmi) {
    if (bmi < 18.5) {
      return "저체중";
    } else if (bmi < 23) {
      return "정상";
    } else if (bmi < 25) {
      return "비만 전단계";
    } else if (bmi < 30) {
      return "1단계 비만";
    } else if (bmi < 35) {
      return "2단계 비만";
    } else {
      return "3단계 비만";
    }
  }

  // BMI에 따른 색상 반환
  Color getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue; // 저체중
    } else if (bmi < 23) {
      return Colors.green; // 정상
    } else if (bmi < 25) {
      return Colors.orange; // 비만 전단계
    } else if (bmi < 30) {
      return Colors.red; // 1단계 비만
    } else if (bmi < 35) {
      return Colors.purple; // 2단계 비만
    } else {
      return Colors.indigo; // 3단계 비만
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bmiColor = getBmiColor(bmi!);
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8, top: 16),
                            child: Text(
                              '체중',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                letterSpacing: -0.1,
                                color: FitnessAppTheme.darkText,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                                    child: Text(
                                      userWeight?.toStringAsFixed(1) ?? '0.0',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 32,
                                        color: FitnessAppTheme.nearlyDarkBlue,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8, bottom: 8),
                                    child: Text(
                                      'kg',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.nearlyDarkBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
                                    child: Text(
                                      bmiResult, // BMI 결과 출력
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        letterSpacing: -0.2,
                                        color: bmiColor, // BMI 색상 적용
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${userHeight?.toStringAsFixed(1) ?? '0.0'} cm',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    '키',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${bmi?.toStringAsFixed(2) ?? '0.00'} BMI',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'BMI 지수',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '${bmr?.toStringAsFixed(1) ?? '0'} kcal',
                                  style: const TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: FitnessAppTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    '기초대사량',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


