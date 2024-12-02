import 'dart:convert';
import 'dart:typed_data';

import 'package:best_flutter_ui_templates/api/api.dart';
import 'package:best_flutter_ui_templates/main.dart';
import 'package:best_flutter_ui_templates/model/loaduser.dart';
import 'package:best_flutter_ui_templates/model/user.dart';
import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/fitness_app/models/meals_list_data.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:best_flutter_ui_templates/fitness_app/my_diary/meal_detail_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 다이얼로그 파일 추가
import 'package:http/http.dart' as http;


class MealsListView extends StatefulWidget {
  final DateTime selectedDate;

  const MealsListView({
    Key? key,
    required this.selectedDate,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  }) : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  // List<MealsListData> mealsListData = MealsListData.tabIconsList;
  List<MealsListData> mealsListData = []; // 빈 리스트로 초기화
  String? userId;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    super.initState();
    _fetchMealsFromServer();
  }

  @override
  void didUpdateWidget(covariant MealsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      // 날짜가 변경되었을 때만 데이터를 다시 로드
      _fetchMealsFromServer();
    }
  }

  Future<void> _fetchMealsFromServer() async {
    User? user = await LoadUser.loadUser();
    userId = user?.user_id;

    if (userId == null) {
      Fluttertoast.showToast(msg: "유저 ID를 찾을 수 없습니다.");
      return;
    }

    try {
      final url = Uri.parse(API.loadUserMenu);
      var response = await http.post(
        url,
        body: {
          'id': userId,
          'date': widget.selectedDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        print("메뉴 정보 불러오기 성공");
        final List<dynamic> data = jsonDecode(response.body);
        print(data);

        final List<MealsListData> loadedMeals =
        data.map((mealJson) => MealsListData.fromJson(mealJson)).toList();

        for (var meal in loadedMeals) {
          if (meal.meals != null && meal.meals!.isNotEmpty) {
            final foodId = meal.meals!.first;
            final details = await _fetchFoodDetails(foodId);

            if (details != null) {
              // foodinfo 데이터 추가
              meal.foodinfo = details['foodid_info']
                  .map<Map<String, dynamic>>((info) => {
                'name': info[1],
                'calories': info[2],
                'carbs': info[3],
                'sugar': info[4],
                'fat': info[5],
                'protein': info[6],
                'sodium': info[7],
                // 'imagePath': info[8], // 서버에서 제공된 파일 경로 사용
              })
                  .toList();

              meal.meals =
                  meal.foodinfo!.map((item) => item['name'].toString()).toList();

              // 총 칼로리 계산
              meal.kcal = meal.foodinfo!.fold(
                0,
                    (sum, item) => sum + (item['calories'] as num).toInt(),
              );
            }
          }
        }

        // 그룹화 및 UI 업데이트
        setState(() {
          mealsListData = _groupMealsByTime(loadedMeals);
        });

        // 디버깅용 최종 데이터 출력
        print("Updated mealsListData: $mealsListData");
      } else {
        print("서버 오류 상태 코드: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching meals: $e');
      Fluttertoast.showToast(msg: '데이터 로드 중 오류가 발생했습니다.');
    }
  }




  Future<Map<String, dynamic>?> _fetchFoodDetails(String foodId) async {
    try {
      final url = Uri.parse(API.loadFoodInfo); // food 상세 정보를 가져오는 API
      final response = await http.post(
        url,
        body: {'foodid': foodId}, // 서버에 foodid 전달
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData != null && responseData['foodid_info'] != null) {
          return responseData; // img_path가 포함된 데이터
        } else {
          print("Error: foodid_info not found in response");
          return null;
        }
      } else {
        print("Failed to fetch food details. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Error fetching food details: $e');
      return null;
    }
  }



  List<MealsListData> _groupMealsByTime(List<MealsListData> meals) {
    Map<String, MealsListData> groupedData = {};

    for (var meal in meals) {
      if (groupedData.containsKey(meal.titleTxt)) {
        // 이미 해당 시간대가 존재하면 데이터 병합
        groupedData[meal.titleTxt]!.kcal += meal.kcal;

        // meals 병합
        var existingMeals = groupedData[meal.titleTxt]!.meals ?? [];
        var newMeals = meal.meals ?? [];
        var uniqueMeals = {...existingMeals, ...newMeals}.toList();
        groupedData[meal.titleTxt]!.meals = uniqueMeals;

        // foodinfo 병합
        var existingFoodInfo = groupedData[meal.titleTxt]!.foodinfo ?? [];
        var newFoodInfo = meal.foodinfo ?? [];
        groupedData[meal.titleTxt]!.foodinfo = [...existingFoodInfo, ...newFoodInfo];
      } else {
        // 새로운 시간대 추가
        groupedData[meal.titleTxt] = MealsListData(
          imagePath: meal.imagePath,
          titleTxt: meal.titleTxt,
          startColor: meal.startColor,
          endColor: meal.endColor,
          meals: List<String>.from(meal.meals ?? []),
          kcal: meal.kcal,
          foodinfo: List<Map<String, dynamic>>.from(meal.foodinfo ?? []),
        );
      }
    }

    // 시간대 순서 지정
    List<String> order = ['아침', '점심', '저녁'];

    // 그룹화된 데이터를 리스트로 변환 후 정렬
    List<MealsListData> sortedList = groupedData.values.toList();
    sortedList.sort((a, b) {
      int aIndex = order.indexOf(a.titleTxt);
      int bIndex = order.indexOf(b.titleTxt);
      return aIndex.compareTo(bIndex); // 순서에 따라 정렬
    });

    // for (var key in sortedList) {
    //   print("Time: ${key.titleTxt}, FoodInfo: ${key.foodinfo}");
    // }

    return sortedList;
  }



  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
              height: 250,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: mealsListData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count =
                  mealsListData.length > 10 ? 10 : mealsListData.length;
                  final Animation<double> animation =
                  Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animationController!,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final MealsListData meal = mealsListData[index];
                          // 디버깅용 foodinfo 출력
                          // print("Food Info for ${meal.titleTxt}: ${meal.foodinfo}");

                          return MealDetailDialog(
                            title: meal.titleTxt, // 시간대
                            foodinfo: meal.foodinfo ?? [], // foodinfo 데이터를 전달
                            kcal: meal.kcal, // 총 칼로리
                            selectedDate: widget.selectedDate,
                          );
                        },
                      );
                    },

                    child: MealsView(
                      mealsListData: mealsListData[index],
                      animation: animation,
                      animationController: animationController!,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper function to decode Base64 and create an Image widget
Widget buildImage(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    return const SizedBox.shrink(); // Return an empty widget if no image
  }
  try {
    Uint8List imageBytes = base64Decode(base64String);
    return Image.memory(
      imageBytes,
      fit: BoxFit.cover,
    );
  } catch (e) {
    print("Error decoding Base64 image: $e");
    return const Icon(Icons.error, color: Colors.white60,); // Display error icon on failure
  }
}

// Modify MealsView to use buildImage
class MealsView extends StatelessWidget {
  const MealsView(
      {Key? key, this.mealsListData, this.animationController, this.animation})
      : super(key: key);

  final MealsListData? mealsListData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: 150,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor(mealsListData!.startColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 5.0),
                        ],
                        gradient: LinearGradient(
                          colors: <HexColor>[
                            HexColor(mealsListData!.startColor),
                            HexColor(mealsListData!.endColor),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              mealsListData!.titleTxt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.2,
                                color: FitnessAppTheme.white,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      mealsListData!.meals!.join('\n'),
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                        letterSpacing: 0.2,
                                        color: FitnessAppTheme.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            mealsListData?.kcal != 0
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  mealsListData!.kcal.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily:
                                    FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                    letterSpacing: 0.2,
                                    color: FitnessAppTheme.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, bottom: 3),
                                  child: Text(
                                    'kcal',
                                    style: TextStyle(
                                      fontFamily:
                                      FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      letterSpacing: 0.2,
                                      color: FitnessAppTheme.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 이미지 수정된 부분
                  Positioned(
                    top: 0,
                    left: 25,
                    child: Container(
                      width: 100, // 이미지 크기 고정
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                        child: buildImage(mealsListData!.imagePath), // buildImage 사용
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}




