import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> get(String url, {String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    try {
      return json.decode(response.body);
    } catch (e) {
      print("API GET decode error: $e");
      return {'status': 'fail', 'message': response.body};
    }
  }

  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data, {String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );

    try {
      return json.decode(response.body);
    } catch (e) {
      print("API POST decode error: $e");
      return {'status': 'fail', 'message': response.body};
    }
  }
}
