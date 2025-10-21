// lib/providers/student_provider.dart

import 'package:flutter/material.dart';
import '../models/student_models.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  // State Properties
  Student? _studentProfile;
  StudentDashboard? _dashboard;
  List<Score> _scores = [];
  Map<String, List<Schedule>> _scheduleByDay = {};
  List<Attendance> _attendanceHistory = [];
  AttendanceSummary? _attendanceSummary;

  bool _isLoading = false;
  String? _error;

  // Getters
  Student? get studentProfile => _studentProfile;
  StudentDashboard? get dashboard => _dashboard;
  List<Score> get scores => _scores;
  Map<String, List<Schedule>> get scheduleByDay => _scheduleByDay;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  AttendanceSummary? get attendanceSummary => _attendanceSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message?.replaceAll('Exception: ', '');
    _isLoading = false;
    notifyListeners();
  }

  // --- Metode Fetching Data ---

  /// [STRATEGI BARU]
  /// Mengganti panggilan tunggal ke /dashboard dengan beberapa panggilan API
  /// yang lebih stabil dan merakit datanya di sisi Flutter.
  Future<void> fetchStudentDashboard(String studentId) async {
    _setLoading(true);
    setError(null);

    try {
      // 1. Jalankan semua panggilan API yang dibutuhkan secara bersamaan
      final results = await Future.wait([
        _studentService.getCurrentStudentProfile(),
        _studentService.getAttendanceSummary(studentId),
        _studentService.getStudentScores(
          studentId,
          limit: 5,
        ), // Ambil 5 nilai terbaru
        _studentService.getStudentSchedule(studentId), // Ambil jadwal seminggu
      ]);

      // 2. Ekstrak hasil dari Future.wait
      final studentProfile = results[0] as Student;
      final attendanceSummaryData = results[1] as AttendanceSummary;
      final recentScores = results[2] as List<Score>;
      final weeklySchedule = results[3] as Map<String, List<Schedule>>;

      // 3. Proses dan rakit data menjadi objek StudentDashboard

      // Hitung rata-rata nilai
      final averageScore =
          recentScores.isNotEmpty
              ? (recentScores.fold<double>(0, (sum, item) => sum + item.value) /
                      recentScores.length)
                  .round()
              : 0;

      // Dapatkan jadwal untuk hari ini dari data mingguan
      final todaySchedule = _getTodaySchedule(weeklySchedule);

      // Buat objek StudentDashboard "buatan" kita
      _dashboard = StudentDashboard(
        student: studentProfile,
        attendanceSummary: attendanceSummaryData.statusSummary,
        attendancePercentage: attendanceSummaryData.overallAttendancePercentage,
        averageScore: averageScore,
        recentScores: recentScores,
        todaySchedule: todaySchedule,
      );

      // Perbarui juga state profil
      _studentProfile = studentProfile;
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Helper untuk mendapatkan jadwal hari ini dari data jadwal mingguan.
  List<Schedule> _getTodaySchedule(Map<String, List<Schedule>> weeklySchedule) {
    // Mapping dari DateTime.weekday (1=Senin, 7=Minggu) ke string nama hari di API
    const Map<int, String> weekdayToString = {
      1: 'SENIN',
      2: 'SELASA',
      3: 'RABU',
      4: 'KAMIS',
      5: 'JUMAT',
      6: 'SABTU',
      7: 'MINGGU',
    };

    final todayWeekday = DateTime.now().weekday;
    final todayKey = weekdayToString[todayWeekday] ?? '';

    return weeklySchedule[todayKey] ??
        []; // Kembalikan list kosong jika tidak ada jadwal
  }

  Future<void> fetchStudentProfile() async {
    // Biasanya ini dipanggil saat ingin refresh data profil
    _setLoading(true);
    setError(null);
    try {
      _studentProfile = await _studentService.getCurrentStudentProfile();
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStudentSchedule(String studentId) async {
    _setLoading(true);
    setError(null);
    try {
      _scheduleByDay = await _studentService.getStudentSchedule(studentId);
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStudentScores(
    String studentId, {
    int page = 1,
    int limit = 20,
  }) async {
    _setLoading(true);
    setError(null);
    try {
      _scores = await _studentService.getStudentScores(
        studentId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAttendanceHistory(
    String studentId, {
    int page = 1,
    int limit = 30,
    String? status,
  }) async {
    _setLoading(true);
    setError(null);
    try {
      _attendanceHistory = await _studentService.getStudentAttendance(
        studentId,
        page: page,
        limit: limit,
        status: status,
      );
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAttendanceSummary(String studentId) async {
    _setLoading(true);
    setError(null);
    try {
      _attendanceSummary = await _studentService.getAttendanceSummary(
        studentId,
      );
    } catch (e) {
      setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- Metode Aksi (Update/Submit) ---

  Future<Map<String, dynamic>> submitAttendance(
    String studentId,
    String token,
  ) async {
    try {
      final result = await _studentService.submitAttendance(studentId, token);
      fetchStudentDashboard(studentId); // Refresh dashboard di background
      return {'success': true, 'data': result};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String gender,
  }) async {
    _setLoading(true);
    setError(null);
    try {
      // Panggil service untuk update
      final updatedStudent = await _studentService.updateStudentProfile(
        name: name,
        gender: gender,
      );
      // Perbarui state lokal
      _studentProfile = updatedStudent;
      // Refresh juga data di dashboard jika ada
      if (_dashboard != null) {
        _dashboard = StudentDashboard(
          student: updatedStudent,
          attendanceSummary: _dashboard!.attendanceSummary,
          attendancePercentage: _dashboard!.attendancePercentage,
          averageScore: _dashboard!.averageScore,
          recentScores: _dashboard!.recentScores,
          todaySchedule: _dashboard!.todaySchedule,
        );
      }
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
