import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Models/EmployeeModel.dart';

class UserInfo {
  static void storeUserInfo(EmployeeModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  static Future<EmployeeModel?> getUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_data');
      if (data != null) {
        final user = EmployeeModel.fromJson(jsonDecode(data));
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('user_data');
  }
}
