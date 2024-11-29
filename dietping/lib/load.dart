import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class LoadUser {
  static Future<Map<String, dynamic>?> loadUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? value = preferences.getString('currentUser');
    if (value != null) {
      // print('haha');
      // print(value);
      return jsonDecode(value);
    } else {
      return null;
    }
  }
}