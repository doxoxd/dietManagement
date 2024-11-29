import 'dart:convert';
import 'dart:ffi';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../cubit/auth_cubit.dart';
import '../model/user.dart';
import '../api/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  //final String $hostConnect; // Flask 서버의 URL을 설정합니다.
  final storage = FlutterSecureStorage(); // Secure Storage 인스턴스

  Future<User> signIn({
    required var id,
    required var password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(API.login), // 로그인 API 엔드포인트
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        if (userData['success'] == true) {
          // 로그인 성공 시
          var val = jsonEncode({
            'id': id,
            'password': password,
          });
          await storage.write(
            key: 'login',
            value: val,  // 로그인 데이터를 안전하게 저장
          );

          // Fluttertoast로 로그인 성공 메시지 표시
          Fluttertoast.showToast(msg: '로그인 성공');

          // 로그인 정보를 User 객체로 변환
          User userInfo = User.fromJson(userData['userData'][0]);

          // 저장된 로그인 정보를 기억하는 메서드 호출
          // 바로 로그인 정보를 저장
          String userJson = jsonEncode(userInfo.toJson()); // User 객체를 JSON 형식으로 변환
          await storage.write(key: 'currentUser', value: userJson); // Secure Storage에 저장

          return userInfo; // JSON을 UserModel로 변환
        } else {
          // 로그인 실패
          Fluttertoast.showToast(msg: '로그인 실패');
          throw Exception('로그인 실패: ${userData['message']}');
        }
      } else {
        Fluttertoast.showToast(msg: '로그인 실패');
        // 서버 응답 실패 시
        throw Exception('Failed to sign in: ${response.body}');
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      Fluttertoast.showToast(msg: '로그인 중 오류 발생');
      throw Exception('로그인 중 오류 발생: $e');
    }
  }

  Future<User> signUp({   // 회원 가입
    required var id,
    required var name,
    required var email,
    required var password,
    required var nickname,
    required int age,
    required var gender,
    required double kcal,
    required double height,
    required double weight
  }) async {
    final response = await http.post(
      Uri.parse(API.signup), // 회원가입 API 엔드포인트
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id' : id,
        'name': name,
        'email': email,
        'password': password,
        'nickname': nickname,
        'age' :age,
        'gender' : gender,
        'kcal' : kcal,
        'height' : height,
        'weight' : weight
      }),
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      return User.fromJson(userData); // JSON을 UserModel로 변환
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  Future<void> signOut() async {
    // 로그아웃은 일반적으로 상태를 관리하는 방식으로 처리되므로, 필요에 따라 구현합니다.
    // 예를 들어, 토큰을 삭제하는 등의 처리를 여기에 추가할 수 있습니다.
  }

  Future<bool> checkUserId({required var id}) async {
    final response = await http.post(
      Uri.parse(API.validateId),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['createId'];  // 생성 가능할 때 true 반환
    } else {
      throw Exception('Failed to validate ID.');
    }
  }

}
