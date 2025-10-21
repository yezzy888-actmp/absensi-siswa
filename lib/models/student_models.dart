// lib/models/student_models.dart

// Helper function to safely parse dates
DateTime? _safeParseDateTime(String? date) {
  if (date == null) return null;
  return DateTime.tryParse(date);
}

// Basic info models used across different responses
class ClassInfo {
  final String id;
  final String name;

  ClassInfo({required this.id, required this.name});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(id: json['id'] ?? '', name: json['name'] ?? 'N/A');
  }
}

class UserInfo {
  final String id;
  final String email;
  final DateTime? createdAt;

  UserInfo({required this.id, required this.email, this.createdAt});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      createdAt: _safeParseDateTime(json['createdAt']),
    );
  }
}

class TeacherInfo {
  final String name;

  TeacherInfo({required this.name});

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(name: json['name'] ?? 'N/A');
  }
}

class Subject {
  final String id;
  final String name;

  Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(id: json['id'] ?? '', name: json['name'] ?? 'N/A');
  }
}

// Core Student Profile Model
class Student {
  final String id;
  final String name;
  final String nis;
  final String gender;
  final ClassInfo classInfo;
  final UserInfo userInfo;

  Student({
    required this.id,
    required this.name,
    required this.nis,
    required this.gender,
    required this.classInfo,
    required this.userInfo,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      nis: json['nis'] ?? 'No NIS',
      gender: json['gender'] ?? 'N/A',
      classInfo: ClassInfo.fromJson(json['class'] ?? {}),
      userInfo: UserInfo.fromJson(json['user'] ?? {}),
    );
  }
}

// Model for Schedule/Timetable
class Schedule {
  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final Subject subject;
  final TeacherInfo teacher;

  Schedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacher,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      day: json['day'] ?? 'N/A',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      subject: Subject.fromJson(json['subject'] ?? {}),
      teacher: TeacherInfo.fromJson(json['teacher'] ?? {}),
    );
  }
}

// Model for a single Score record
class Score {
  final String id;
  final String type;
  final double value;
  final String? description;
  final DateTime? createdAt;
  final Subject subject;

  Score({
    required this.id,
    required this.type,
    required this.value,
    this.description,
    this.createdAt,
    required this.subject,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] ?? '',
      type: json['type'] ?? 'N/A',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      createdAt: _safeParseDateTime(json['createdAt']),
      subject: Subject.fromJson(json['subject'] ?? {}),
    );
  }
}

// Model for a single Attendance record
class Attendance {
  final String id;
  final String status;
  final DateTime date;
  final Schedule schedule;

  Attendance({
    required this.id,
    required this.status,
    required this.date,
    required this.schedule,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      status: json['status'] ?? 'ALPHA',
      date: _safeParseDateTime(json['date']) ?? DateTime.now(),
      schedule: Schedule.fromJson(json['schedule'] ?? {}),
    );
  }
}

// Model for the response of the Dashboard endpoint
class StudentDashboard {
  final Student student;
  final Map<String, int> attendanceSummary;
  final int attendancePercentage;
  final int averageScore;
  final List<Score> recentScores;
  final List<Schedule> todaySchedule;

  StudentDashboard({
    required this.student,
    required this.attendanceSummary,
    required this.attendancePercentage,
    required this.averageScore,
    required this.recentScores,
    required this.todaySchedule,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    // Parse attendance summary
    final summary = json['attendanceSummary'] ?? {};
    final Map<String, int> attendanceMap = {
      'HADIR': (summary['HADIR'] as num?)?.toInt() ?? 0,
      'IZIN': (summary['IZIN'] as num?)?.toInt() ?? 0,
      'SAKIT': (summary['SAKIT'] as num?)?.toInt() ?? 0,
      'ALPHA': (summary['ALPHA'] as num?)?.toInt() ?? 0,
    };

    // Parse recent scores
    final scoresList = json['recentScores'] as List? ?? [];
    final List<Score> parsedScores =
        scoresList.map((item) => Score.fromJson(item)).toList();

    // Parse today's schedule
    final scheduleList = json['todaySchedule'] as List? ?? [];
    final List<Schedule> parsedSchedule =
        scheduleList.map((item) => Schedule.fromJson(item)).toList();

    return StudentDashboard(
      student: Student.fromJson(json['student'] ?? {}),
      attendanceSummary: attendanceMap,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toInt() ?? 0,
      recentScores: parsedScores,
      todaySchedule: parsedSchedule,
    );
  }
}

// Model untuk statistik absensi per mata pelajaran
class SubjectAttendanceStats {
  final String subjectId;
  final String subjectName;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;
  final int total;
  final int attendancePercentage;

  SubjectAttendanceStats({
    required this.subjectId,
    required this.subjectName,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
    required this.total,
    required this.attendancePercentage,
  });

  factory SubjectAttendanceStats.fromJson(Map<String, dynamic> json) {
    return SubjectAttendanceStats(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? 'N/A',
      hadir: (json['HADIR'] as num?)?.toInt() ?? 0,
      izin: (json['IZIN'] as num?)?.toInt() ?? 0,
      sakit: (json['SAKIT'] as num?)?.toInt() ?? 0,
      alpha: (json['ALPHA'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toInt() ?? 0,
    );
  }
}

// Model untuk response lengkap dari endpoint attendance-summary
class AttendanceSummary {
  final Map<String, int> statusSummary;
  final int overallAttendancePercentage;
  final List<SubjectAttendanceStats> subjectStats;

  AttendanceSummary({
    required this.statusSummary,
    required this.overallAttendancePercentage,
    required this.subjectStats,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['statusSummary'] ?? {};
    final Map<String, int> statusMap = {
      'HADIR': (summary['HADIR'] as num?)?.toInt() ?? 0,
      'IZIN': (summary['IZIN'] as num?)?.toInt() ?? 0,
      'SAKIT': (summary['SAKIT'] as num?)?.toInt() ?? 0,
      'ALPHA': (summary['ALPHA'] as num?)?.toInt() ?? 0,
    };

    final statsList = json['subjectStats'] as List? ?? [];
    final List<SubjectAttendanceStats> parsedStats =
        statsList.map((item) => SubjectAttendanceStats.fromJson(item)).toList();

    return AttendanceSummary(
      statusSummary: statusMap,
      overallAttendancePercentage:
          (json['overallAttendancePercentage'] as num?)?.toInt() ?? 0,
      subjectStats: parsedStats,
    );
  }
}
