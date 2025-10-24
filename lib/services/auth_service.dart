import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'https://absen-blond.vercel.app/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys untuk storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login untuk student
  Future<Map<String, dynamic>> loginStudent(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token dan data user
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));

        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // Login untuk teacher
  Future<Map<String, dynamic>> loginTeacher(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/teacher'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));

        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        return data['user'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  // Get saved user data
  Future<Map<String, dynamic>?> getSavedUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
