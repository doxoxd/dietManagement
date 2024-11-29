import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지
import '../api/api.dart';
import 'category_food.dart';
import 'course_info_screen.dart'; // CourseInfoScreen을 가져옵니다.

class Category {
  final String contents;
  final String foodname;
  final String image;
  final String menucode;
  final String menuname;

  Category({
    required this.contents,
    required this.foodname,
    required this.image,
    required this.menucode,
    required this.menuname,
  });

  // JSON 데이터를 Category 객체로 변환하는 함수
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      contents: json['contents'] ?? '',
      foodname: json['foodname'] ?? '',
      image: json['image'] ?? '',
      menucode: json['menucode']?.toString() ?? '',
      menuname: json['menuname'] ?? '',
    );
  }
}

class PopularCourseList extends StatefulWidget {
  final String menucode;
  const PopularCourseList({Key? key, required this.menucode}) : super(key: key);

  @override
  _PopularCourseListState createState() => _PopularCourseListState();
}

class _PopularCourseListState extends State<PopularCourseList> {
  late Future<List<Category>> popularCourses;

  @override
  void initState() {
    super.initState();
    popularCourses = fetchPopularCourses(); // 서버에서 인기 코스를 받아옴
  }

  // 서버에서 인기 코스 목록을 받아오는 함수
  Future<List<Category>> fetchPopularCourses() async {
    try {
      final response = await http.post(Uri.parse(API.loadCategoryMenu), body: {
        'categoryid': widget.menucode,
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> categorymenu = jsonResponse['categorymenu'] ?? [];
        return categorymenu.map((course) => Category.fromJson(course)).toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('특별한 식단')),
      body: FutureBuilder<List<Category>>(
        future: popularCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available.'));
          } else {
            List<Category> courses = snapshot.data!;

            // 세로 리스트뷰로 구성
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final category = courses[index];
                return InkWell(
                  onTap: () {
                    // CourseInfoScreen으로 이동하고 선택된 Course의 code 전달
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            categoryfood(menuCode: category.menucode),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      children: [
                        // 이미지
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: NetworkImage(category.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // 메뉴 이름
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              category.menuname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
