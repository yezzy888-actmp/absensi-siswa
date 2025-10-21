// lib/services/student_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/student_models.dart';

class StudentService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Not authenticated: Token not found.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    final decodedBody = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    } else {
      throw Exception(decodedBody['message'] ?? 'An unknown error occurred.');
    }
  }

  /// Fetches the detailed profile for the currently authenticated student
  Future<Student> getCurrentStudentProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/me/profile'),
        headers: headers,
      );
      final data = _handleResponse(response);
      return Student.fromJson(data['profile']);
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the current student's profile
  Future<Student> updateStudentProfile({
    required String name,
    required String gender,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({'name': name, 'gender': gender});
      final response = await http.put(
        Uri.parse('$baseUrl/students/me/profile'),
        headers: headers,
        body: body,
      );
      final data = _handleResponse(response);
      return Student.fromJson(data['student']);
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the dashboard summary for a specific student ID
  Future<StudentDashboard> getStudentDashboard(String studentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/$studentId/dashboard'),
        headers: headers,
      );
      final data = _handleResponse(response);
      return StudentDashboard.fromJson(data);
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the schedule for a student
  Future<Map<String, List<Schedule>>> getStudentSchedule(
    String studentId,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/students/$studentId/schedule');
      final response = await http.get(uri, headers: headers);
      final data = _handleResponse(response);
      final scheduleData = data['schedule'];
      Map<String, List<Schedule>> scheduleByDay = {};
      if (scheduleData is Map) {
        scheduleData.forEach((day, schedulesJson) {
          final schedulesList =
              (schedulesJson as List)
                  .map((item) => Schedule.fromJson(item))
                  .toList();
          scheduleByDay[day] = schedulesList;
        });
      }
      return scheduleByDay;
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a paginated list of a student's scores
  Future<List<Score>> getStudentScores(
    String studentId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {'page': page.toString(), 'limit': limit.toString()};
      final uri = Uri.parse(
        '$baseUrl/students/$studentId/scores',
      ).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      final data = _handleResponse(response);
      final scoresList = data['scores'] as List;
      return scoresList.map((item) => Score.fromJson(item)).toList();
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a paginated list of a student's attendance records
  Future<List<Attendance>> getStudentAttendance(
    String studentId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) {
        params['status'] = status;
      }
      final uri = Uri.parse(
        '$baseUrl/students/$studentId/attendance',
      ).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);
      final data = _handleResponse(response);
      final attendanceList = data['attendances'] as List;
      return attendanceList.map((item) => Attendance.fromJson(item)).toList();
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the attendance summary for a student
  Future<AttendanceSummary> getAttendanceSummary(String studentId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/students/$studentId/attendance-summary');
      final response = await http.get(uri, headers: headers);
      final data = _handleResponse(response);
      return AttendanceSummary.fromJson(data);
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  /// Submits attendance for a student using a session token
  Future<Map<String, dynamic>> submitAttendance(
    String studentId,
    String token,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({'token': token});
      final response = await http.post(
        Uri.parse('$baseUrl/students/$studentId/submit-attendance'),
        headers: headers,
        body: body,
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      rethrow;
    }
  }
}
