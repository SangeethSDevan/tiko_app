import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  bool get isLoggedIn => token != null;

  /// Login method
  Future<bool> login(String credential, String password) async {
    try {
      final res = await ApiService.post(
        LOGIN_URL,
        {'credential': credential, 'password': password},
      );
      print("Login response: $res");

      if (res['status'] == 'success') {
        token = res['token'];
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  /// Signup method
  Future<bool> signup(
      String name, String username, String email, String password) async {
    try {
      final res = await ApiService.post(
        SIGNUP_URL,
        {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        },
      );
      print("Signup response: $res");

      if (res['status'] == 'success') {
        token = res['token'];
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Signup error: $e");
    }
    return false;
  }

  /// Logout method
  void logout() {
    token = null;
    notifyListeners();
  }
}
