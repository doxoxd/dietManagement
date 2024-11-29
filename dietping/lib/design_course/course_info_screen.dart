import 'package:flutter/material.dart';
import 'design_course_app_theme.dart';
import 'editInfo.dart';

class CourseInfoScreen extends StatefulWidget {
  @override
  _CourseInfoScreenState createState() => _CourseInfoScreenState();
}

class _CourseInfoScreenState extends State<CourseInfoScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignCourseAppTheme.nearlyWhite, // 전체 배경색
      body: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, -20), // 위쪽으로 이동 조정 (살짝만 위로 이동)
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80.0), // 상단 패딩
                  // 프로필 사진
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage(
                        'assets/design_course/profile.jpg'), // 프로필 이미지 경로
                    backgroundColor: DesignCourseAppTheme.nearlyWhite,
                  ),
                  const SizedBox(height: 10.0),
                  // 닉네임
                  Text(
                    '닉네임',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  // 북마크 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      // 북마크 기능 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF749BE4), // 요청된 파란색
                      minimumSize: Size(200, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    icon: const Icon(Icons.bookmark,
                        color: Colors.white, size: 28),
                    label: const Text(
                      '북마크',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // 로그아웃 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      // 로그아웃 기능 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF749BE4), // 요청된 파란색
                      minimumSize: Size(200, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    icon:
                    const Icon(Icons.logout, color: Colors.white, size: 28),
                    label: const Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // 회원정보 수정 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      // 회원정보 수정 로직 추가
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => UserEditScreen(),
                      ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF749BE4), // 요청된 파란색
                      minimumSize: Size(200, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                    label: const Text(
                      '회원정보 수정',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}