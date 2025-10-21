import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // Cek status login saat app dimulai
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _user = await _authService.getSavedUser();
      // Refresh user data dari server
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login sebagai student
  Future<Map<String, dynamic>> loginStudent(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.loginStudent(email, password);

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Login sebagai teacher
  Future<Map<String, dynamic>> loginTeacher(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.loginTeacher(email, password);

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
