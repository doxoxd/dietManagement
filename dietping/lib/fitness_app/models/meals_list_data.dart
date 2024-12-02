// 식단 기록한 거 보여주는 부분
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../api/api.dart';


class MealsListData {
  List<Map<String, dynamic>>? foodinfo; // foodinfo 데이터를 저장
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kcal = 0,
    this.foodinfo,
    this.imageData, // Base64 디코딩된 이미지 데이터를 저장
  });

  String imagePath; // Base64 이미지 데이터 또는 기본 이미지 경로
  String titleTxt; // 시간대 (아침, 점심, 저녁)
  String startColor; // 시작 색상
  String endColor; // 끝 색상
  List<String>? meals; // 음식 ID 리스트
  int kcal; // 칼로리 정보
  Uint8List? imageData; // Base64 디코딩된 이미지 데이터

  @override
  String toString() {
    return 'MealsListData(titleTxt: $titleTxt, meals: $meals, kacl: $kcal)';
  }
/*  static List<MealsListData> tabIconsList = <MealsListData>[
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
  ];*/

  factory MealsListData.fromJson(Map<String, dynamic> json) {
    // 시간대에 따라 기본 이미지 경로를 선택
    String getImagePath(String time) {
      switch (time) {
        case '아침':
          return 'assets/fitness_app/breakfast.png';
        case '점심':
          return 'assets/fitness_app/lunch.png';
        case '저녁':
          return 'assets/fitness_app/dinner.png';
        default:
          return 'assets/fitness_app/default_image.png';
      }
    }

    // 시간대에 따라 시작 색상 선택
    String getStartColor(String time) {
      switch (time) {
        case '아침':
          return '#8E94CCFF';
        case '점심':
          return '#738AE6';
        case '저녁':
          return '#6F72CA';
        default:
          return '#FFFFFF';
      }
    }

    // 시간대에 따라 끝 색상 선택
    String getEndColor(String time) {
      switch (time) {
        case '아침':
          return '#8E94CCFF';
        case '점심':
          return '#5C5EDD';
        case '저녁':
          return '#1E1466';
        default:
          return '#FFFFFF';
      }
    }

    // foodid 처리
    List<String> foodIds = [];
    if (json['foodid'] != null) {
      if (json['foodid'] is String) {
        foodIds.add(json['foodid']); // 단일 foodid 처리
      } else if (json['foodid'] is List) {
        foodIds = List<String>.from(json['foodid']); // 리스트 처리
      }
    }

    return MealsListData(
      imagePath: json['img'] != null && json['img'].isNotEmpty
          ? json['img'] // 이미지 경로로 처리
          : getImagePath(json['time'] ?? '기타'), // 기본 이미지 경로
      titleTxt: json['time'] ?? '식사',
      startColor: getStartColor(json['time'] ?? '기타'),
      endColor: getEndColor(json['time'] ?? '기타'),
      meals: foodIds.isNotEmpty ? foodIds : [], // foodid 리스트
      kcal: json['kcal'] ?? 0, // 칼로리 정보 없으면 기본값 0
    );
  }
}