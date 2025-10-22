import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  bool get isLoggedIn => token != null;

  Future<bool> login(String credential, String password) async {
    final res = await ApiService.post(LOGIN_URL, {'credential': credential, 'password': password});
    if (res['status'] == 'success') {
      token = res['token'];
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String username, String email, String password) async {
    final res = await ApiService.post(SIGNUP_URL, {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });

    if (res['status'] == 'success') {
      token = res['token'];
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    token = null;
    notifyListeners();
  }
}
