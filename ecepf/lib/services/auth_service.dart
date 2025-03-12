import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/auth/';
  static Future<bool> register(String username, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'register/'),
      body: jsonEncode({'username': username, 'email': email, 'password': password, 'role': role}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);
      
      return true;
    }
    return false;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + 'login/'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      print('Raw login response: ${response.body}');
      final data = jsonDecode(response.body);
      print('Parsed login data: $data');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['role']);
        await prefs.setInt('userId', data['id']);
        print('User ID stored: ${data['id']}');
        

        return {
          'token': data['token'],
          'role': data['role'],
          'id': data['id'],
        };
      } else {
        print('Login failed: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
