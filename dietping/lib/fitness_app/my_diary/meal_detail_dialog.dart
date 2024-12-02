import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api/api.dart';
import '../../model/loaduser.dart';
import '../../model/user.dart';

class MealDetailDialog extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> foodinfo;
  final int kcal;
  final DateTime selectedDate;

  const MealDetailDialog({
    Key? key,
    required this.title,
    required this.foodinfo,
    required this.kcal,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _MealDetailDialogState createState() => _MealDetailDialogState();
}

class _MealDetailDialogState extends State<MealDetailDialog> {
  bool isLoading = false;

  // 삭제 요청과 record DB 업데이트를 처리하는 함수
  Future<bool> _deleteMealAndUpdateRecord() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. 삭제 요청
      bool deleteSuccess = await _deleteMealFromServer();
      if (!deleteSuccess) return false;

      // 2. record DB 업데이트
      bool updateSuccess = await _updateRecordDB();
      return updateSuccess;
    } catch (e) {
      print("삭제 및 업데이트 중 오류 발생: $e");
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 식단 삭제 서버 요청
  Future<bool> _deleteMealFromServer() async {
    User? user = await LoadUser.loadUser();
    try {
      final url = Uri.parse(API.deleteMenu); // 삭제 API 주소
      final response = await http.post(
        url,
        body: {
          'userid': user?.user_id, // 유저 ID
          'date': widget.selectedDate.toIso8601String(), // 선택된 날짜 (예: 오늘)
          'time': widget.title, // 삭제할 시간대 (예: "아침")
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print("삭제 요청 중 오류 발생: $e");
      return false;
    }
  }

  // record DB 업데이트
  Future<bool> _updateRecordDB() async {
    try {
      User? user = await LoadUser.loadUser();
      if (user == null) return false;

      // 삭제된 데이터를 반영하여 새로운 총 영양소 값 계산
      double updatedCalories = 0.0;
      double updatedCarbs = 0.0;
      double updatedSugar = 0.0;
      double updatedFat = 0.0;
      double updatedProtein = 0.0;
      double updatedSodium = 0.0;

      for (var food in widget.foodinfo) {
        updatedCalories += (food['calories'] as num).toDouble();
        updatedCarbs += (food['carbs'] as num).toDouble();
        updatedSugar += (food['sugar'] as num).toDouble();
        updatedFat += (food['fat'] as num).toDouble();
        updatedProtein += (food['protein'] as num).toDouble();
        updatedSodium += (food['sodium'] as num).toDouble();
      }

      final url = Uri.parse(API.updateUserDiary); // 영양소 업데이트 API
      final response = await http.post(
        url,
        body: {
          'userid': user.user_id,
          'date': widget.selectedDate.toIso8601String(),
          'tcal': updatedCalories.toString(),
          'tcarbs': updatedCarbs.toString(),
          'tsugar': updatedSugar.toString(),
          'tfat': updatedFat.toString(),
          'tprotein': updatedProtein.toString(),
          'tsodium': updatedSodium.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      }
      return false;
    } catch (e) {
      print("record DB 업데이트 중 오류 발생: $e");
      return false;
    }
  }

  // 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "삭제 확인",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF333333),
            ),
          ),
          content: Text(
            "정말 삭제하시겠습니까?",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "아니오",
                style: TextStyle(
                  color: Color(0xFF999999),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // 다이얼로그 닫기
                bool success = await _deleteMealAndUpdateRecord();
                if (success) {
                  Navigator.pop(context); // 메인 다이얼로그 닫기
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("삭제 및 기록 업데이트 실패")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF759CE6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "예",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목과 닫기 버튼 (오른쪽 끝)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF759CE6),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context), // 닫기 버튼
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 음식 상세 정보
              Expanded(
                child: ListView.builder(
                  itemCount: widget.foodinfo.length,
                  itemBuilder: (context, index) {
                    final item = widget.foodinfo[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "- ${item['name']} (${item['calories']} kcal)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "탄수화물: ${item['carbs']}g, "
                                "당류: ${item['sugar']}g, "
                                "지방: ${item['fat']}g, "
                                "단백질: ${item['protein']}g, "
                                "나트륨: ${item['sodium']}mg",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 0.8,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 총 칼로리 정보
              Text(
                "총 칼로리: ${widget.kcal} kcal",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // 삭제 버튼
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                ),
                child: Text(
                  "삭제",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

