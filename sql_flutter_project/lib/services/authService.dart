import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://localhost:7106/auth';

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      final token = body['token'];
      print("JWT Token: $token");

      await prefs.setString('jwt', token);
      await prefs.setString('role', body['user']['role']);
      await prefs.setString('username', body['user']['username']);
      return true;
    }

    return false;
  }



  Future<bool> register(String username, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"username": username, "password": password, "role": role}),
    );
    return response.statusCode == 200;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}