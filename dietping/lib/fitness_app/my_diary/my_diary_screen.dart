import 'dart:convert';

import 'package:best_flutter_ui_templates/api/api.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/diary_record_dialog.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/water_dialog.dart';
import 'package:best_flutter_ui_templates/fitness_app/ui_view/body_measurement.dart';
import 'package:best_flutter_ui_templates/fitness_app/ui_view/total_view.dart';
import 'package:best_flutter_ui_templates/fitness_app/ui_view/title_view.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/meals_list_view.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/water_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:image_picker/image_picker.dart';

import '../../model/loaduser.dart';
import 'body_info_dialog.dart';
import 'food_search_dialog.dart';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen> {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  String? userId; // 유저 ID 저장
  Map<String, dynamic>? userData;
  List<List<dynamic>> data = [];

  // 현재 선택된 날짜
  DateTime selectedDate = DateTime.now();

  // 날짜를 "00월 00일" 형식으로 반환하는 메소드
  String _getFormattedDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0'); // 두 자리 숫자
    final String day = date.day.toString().padLeft(2, '0');     // 두 자리 숫자
    return "$month월 $day일";
  }

  @override
  void initState() {
    _loadUserId(); // 유저 ID 로드
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  // 유저 ID를 서버에서 가져오는 메서드
  Future<void> _loadUserId() async {
    userData = (await LoadUser.loadUser()) as Map<String, dynamic>?;
    userId = userData?['id'];

    try {
      var res = await http.post(
          Uri.parse(API.loadUser),
          body: {
            'id': userId,
          }
      );
      if (res.statusCode == 200) {
        var resLoadD = jsonDecode(res.body);
        if (resLoadD['result'] == 'true') {
          setState(() {
            data = (resLoadD['user_info'] as List).cast<List<dynamic>>();
            print(data);
          });
          addAllListData(); // 유저 ID 로드 후 리스트 데이터 다시 추가
        } else {
          print("유저 정보 로드 실패");
        }
      } else {
        print("HTTP 요청 실패");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }


  // 날짜를 전날로 변경
  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
    });
  }

  // 날짜를 다음 날로 변경
  void _nextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
    });
  }
  // 날짜 선택 위젯 표시
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('ko'), // 한국어 설정
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF759CE6), // 헤더 색상, 확인 버튼 색상
            hintColor: Color(0xFF759CE6), // 캘린더 선택된 날짜 색상
            colorScheme: ColorScheme.light(primary: Color(0xFF759CE6)),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // 확인, 취소 버튼 색상
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void addAllListData() {
    const int count = 9;

    listViews.add(
      TitleView(
        titleTxt: '영양 성분',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      TotalView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        selectedDate: selectedDate, // 선택한 날짜만 전달
      ),
    );
    /*listViews.add(
      TotalView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!, userId: '', selectedDate: '',
      ),
    );*/
    listViews.add(
      Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TitleView(
                titleTxt: '식단 기록',
                subTxt: '',
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController!,
                    curve: Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                animationController: widget.animationController!,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _showTextRecordDialog, // Dialog 표시 함수 연결
                  child: Row(
                    children: [
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: FitnessAppTheme.nearlyDarkBlue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: FitnessAppTheme.darkText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    listViews.add(
      MealsListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
      ),
    );
    listViews.add(
      Padding(
          padding: const EdgeInsets.only(right: 15.0), // 좌우 여백 추가
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TitleView(
                  titleTxt: '신체 정보',
                  subTxt: '',
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn),
                    ),
                  ),
                  animationController: widget.animationController!,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _showBodyInfoDialog, // 다이얼로그 호출
                    child: Row(
                      children: [
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            color: FitnessAppTheme.nearlyDarkBlue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: FitnessAppTheme.darkText,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
    listViews.add(
      BodyMeasurementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TitleView(
                titleTxt: '물 섭취',
                subTxt: '',
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController!,
                    curve: Interval((1 / count) * 6, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                animationController: widget.animationController!,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _showWaterDialog, // WaterDialog 연결
                  child: Row(
                    children: [
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: FitnessAppTheme.nearlyDarkBlue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: FitnessAppTheme.darkText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );


    listViews.add(
      WaterView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 7, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController!,
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }
  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'My Diary',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            // 왼쪽 화살표 버튼 (전날로 이동)
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(32.0)),
                                onTap: _previousDay, // 전날로 이동
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                            // 날짜 표시 및 클릭 시 날짜 선택 위젯 표시
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: InkWell(
                                onTap: _selectDate, // 날짜 선택 위젯 표시
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: FitnessAppTheme.grey,
                                        size: 18,
                                      ),
                                    ),
                                    Text(
                                      _getFormattedDate(selectedDate), // 날짜 표시 (00월 00일)
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.darkerText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 오른쪽 화살표 버튼 (다음 날로 이동)
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(32.0)),
                                onTap: _nextDay, // 다음 날로 이동
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
  /*void _showMealSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      backgroundColor: Colors.transparent, // Dialog 배경 투명
      isScrollControlled: true, // 높이 조절 가능
      builder: (BuildContext context) {
        return MealSelectionDialog(
          onTextRecord: () {
            Navigator.pop(context); // MealSelectionDialog 닫기
            _showTextRecordDialog(); // TextRecordDialog 표시
          },
          onTakePhoto: () {
            Navigator.pop(context);
            print("사진 촬영 선택");
          },
          onFindInAlbum: () {
            Navigator.pop(context);
            print("앨범에서 선택");
          },
          onRecordNutrients: () {
            Navigator.pop(context);
            _showFoodRecordDialog(); // 영양 성분 기록 다이얼로그 호출
          },
        );
      },
    );
  }*/

  void _showTextRecordDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DiaryRecordDialog(); // 다이얼로그 호출
      },
    );
  }


  void _showBodyInfoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 스크롤 가능
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return BodyInfoDialog(
          onSave: (String height, String weight, String gender, String age) {
            print("키: $height cm, 몸무게: $weight kg, 성별: $gender, 나이: $age");
            // 저장 로직 추가
          },
        );
      },
    );
  }
  void _showWaterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return WaterDialog(
          currentIntake: 1000, // 기본 섭취량
          goalIntake: 2000, // 기본 목표 섭취량
          onSave: (currentIntake, goalIntake) {
            // 저장 로직 처리
            print("섭취량: $currentIntake ml");
            print("목표 섭취량: $goalIntake ml");
          },
        );
      },
    );
  }

}