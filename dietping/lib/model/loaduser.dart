import 'dart:convert';
import 'package:best_flutter_ui_templates/model/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage 임포트

class LoadUser {
  final storage = FlutterSecureStorage(); // Secure Storage 인스턴스

  // Secure Storage에서 사용자 정보 불러오기
  static Future<User?> loadUser() async {
    final storage = FlutterSecureStorage(); // Secure Storage 인스턴스
    String? userJson = await storage.read(key: 'currentUser');

    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson); // JSON을 Map으로 변환
      return User.fromJson(userMap); // Map을 User 객체로 변환하여 반환
    } else {
      return null; // 값이 없으면 null 반환
    }
  }
}
