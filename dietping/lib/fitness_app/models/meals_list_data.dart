// 식단 기록한 거 보여주는 부분
import 'package:http/http.dart' as http;

import '../../api/api.dart';


class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: '아침',
      kacl: 540,
      meals: <String>['현미잡곡밥,', '된장국,', '김치'],
      startColor: '#8E94CCFF',
      endColor: '#8E94CCFF',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: '점심',
      kacl: 305,
      meals: <String>['차조밥,', '콩나물국,', '감자조림'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: '저녁',
      kacl: 330,
      meals: <String>['새싹비빔밥', '동치미'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}