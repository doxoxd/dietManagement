import 'package:flutter/material.dart';

class MealDetailDialog extends StatelessWidget {
  final String title;
  final List<String> meals;
  final int kacl;

  const MealDetailDialog({
    Key? key,
    required this.title,
    required this.meals,
    required this.kacl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // 배경 색상 직접 설정
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 흰색으로 설정
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF759CE6), // 파란 제목 색상
                ),
              ),
              const SizedBox(height: 16),
              // 음식 목록
              Text(
                "음식 목록:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ...meals.map((meal) => Text(
                "- $meal",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              )),
              const SizedBox(height: 16),
              // 총 칼로리
              Text(
                "총 칼로리: $kacl kcal",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // 닫기 버튼
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF759CE6), // 파란색 버튼
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  "닫기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // 버튼 텍스트 흰색
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