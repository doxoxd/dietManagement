import 'dart:convert';
import 'dart:io';

// import 'package:best_flutter_ui_templates/hotel_booking/saveinfo.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../api/api.dart';
import '../model/loaduser.dart';
import '../model/user.dart';

class AddRecipeinfo extends StatelessWidget {
  const AddRecipeinfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로운 레시피 추가'),
      ),
      body: AddRecipeForm(),
    );
  }
}

class AddRecipeForm extends StatefulWidget {
  @override
  _AddRecipeFormState createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  String imagePath = '';
  String titleTxt = '';
  String subTxt = '';
  int calories = 0;
  XFile? selectedImage; // 선택된 이미지 파일
  List<XFile> selectedImages = []; // 선택된 이미지 목록
  List<List<dynamic>> addrecipe =[];
  final ImagePicker picker = ImagePicker();
  String? userID; //


  // 갤러리 또는 카메라에서 이미지 선택
  Future<void> _selectMultipleImages() async {
    try {
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null) {
        // 최대 3장의 이미지만 선택
        setState(() {
          selectedImages = images.take(3).toList();
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }
  Future<void> getImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (selectedImages.length < 3) {
            selectedImages.add(image); // 이미지 추가
          } else {
            print("최대 3장의 이미지만 선택 가능합니다.");
          }
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }
// 서버 응답 처리
  Future<void> loadsave({required bool withImage}) async {
    User? user = await LoadUser.loadUser();
    userID = user?.user_id;
    print(userID);

    // if (userID == null) {
    //   Fluttertoast.showToast(msg: "유저 ID를 찾을 수 없습니다.");
    //   return;
    // }

    for (var community in addrecipe) {
      try {
        // 서버 URL 설정
        final url = Uri.parse(API.addrecipe);

        // 이미지 데이터를 Base64로 인코딩
        List<String> encodedImages = [];
        if (withImage) {
          for (var img in selectedImages) {
            final bytes = await File(img.path).readAsBytes();
            final base64Image = base64Encode(bytes);
            encodedImages.add(base64Image);
          }
        }

        // JSON 데이터 생성
        Map<String, dynamic> jsonData = {
          'id': userID,
          'community': {
            'id': community[0],
            'userid': community[1],
            'title': community[2],
            'picture': community[3],
            'post': community[4],
            'kcal': community[5],
            'ingredient': community[6],
          },
          'images': encodedImages,
        };

        print("전송할 데이터: $jsonData");

        // 요청 전송
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(jsonData),
        );

        // 응답 처리
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          print("서버 응답 내용: $jsonResponse"); // 서버 응답 내용 출력
          if (jsonResponse['result'] == 'true') {
            Fluttertoast.showToast(msg: "음식 '${community[2]}' 저장 성공");
          } else {
            Fluttertoast.showToast(
                msg: "음식 '${community[2]}' 저장 실패: ${jsonResponse['message']}");
          }
        } else {
          print("HTTP 오류 발생: ${response.statusCode}"); // HTTP 오류 코드 출력
          Fluttertoast.showToast(msg: "HTTP 오류: ${response.statusCode}");
        }
      } catch (e) {
        print("요청 중 오류 발생: $e"); // 예외 발생 시 오류 내용 출력
        Fluttertoast.showToast(msg: "음식 '${community[2]}' 저장 중 오류 발생: $e");
      }
    }
  }


  // 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: '제목'),
              onSaved: (value) {
                titleTxt = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '내용'),
              onSaved: (value) {
                subTxt = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '칼로리'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                calories = int.parse(value!);
              },
            ),
            SizedBox(height: 20),

            // 사진 추가 섹션
            Text(
              "사진 추가",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // 선택된 이미지 또는 버튼 표시
            if (selectedImages.isNotEmpty)
              Wrap(
                spacing: 8, // 이미지 간의 수평 간격
                runSpacing: 8, // 이미지 간의 수직 간격
                children: selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(image.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeImage(index), // 개별 이미지 삭제
                        icon: Icon(Icons.close, color: Colors.red),
                        tooltip: "이미지 삭제",
                      ),
                    ],
                  );
                }).toList(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconCard(
                    icon: Icons.camera_alt,
                    label: "사진 촬영",
                    onPressed: () async {
                      await getImage(ImageSource.camera); // 카메라로 사진 촬영
                    },
                  ),
                  _buildIconCard(
                    icon: Icons.photo_library,
                    label: "앨범 선택",
                    onPressed: () async {
                      await _selectMultipleImages(); // 갤러리에서 여러 사진 선택
                    },
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();

                  // 저장된 데이터를 처리
                  print('이미지 경로: $imagePath');
                  print('제목: $titleTxt');
                  print('내용: $subTxt');
                  print('칼로리: $calories');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('레시피가 저장 중입니다...')),
                  );

                  // 서버에 저장 로직 호출
                  await loadsave(withImage: selectedImages.isNotEmpty);

                  // 저장이 완료된 후 페이지 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRecipeinfo(), // AddRecipeinfo로 이동
                    ),
                  );
                }
              },
              child: Text('저장하기'),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildIconCard({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 130,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: Color(0xFF0066CC),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}