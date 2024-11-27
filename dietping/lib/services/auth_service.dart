import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import '../cubit/auth_cubit.dart';
import '../model/user.dart';
import '../api/api.dart';
class AuthService {
  //final String $hostConnect; // Flask 서버의 URL을 설정합니다.

  Future<User> signIn({
    required var id,
    required var password,
  }) async {
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
      return User.fromJson(userData); // JSON을 UserModel로 변환
    } else {
      throw Exception('Failed to sign in: ${response.body}');
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
