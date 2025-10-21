// lib/screens/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';
import 'package:absensi_siswa/theme/color_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // UI/UX Tip: Menggunakan 'addPostFrameCallback' memastikan context sudah siap
    // saat kita memanggil provider. Ini adalah cara yang aman untuk fetch data di initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSchedule();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Helper method untuk memanggil provider dan mengambil data.
  void _fetchSchedule() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.user?['profileData']?['id'];

    if (studentId != null) {
      // Panggil method di provider. Kita tidak butuh return value di sini.
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).fetchStudentSchedule(studentId);
    } else {
      // Jika ID tidak ada, kita bisa set error di provider.
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).setError("ID Siswa tidak ditemukan. Silakan login ulang.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColorTheme.backgroundLinearGradient,
        ),
        child: Column(
          children: [
            // Custom App Bar with gradient
            _buildCustomAppBar(),

            // Main Content with proper bottom padding
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, studentProvider, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContent(studentProvider),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorTheme.blueColors[500]!,
            AppColorTheme.blueColors[600]!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorTheme.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColorTheme.blueColors[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Pelajaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.primaryForeground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Kelola jadwal harian Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorTheme.primaryForeground.withValues(
                      alpha: 0.8,
                    ),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StudentProvider studentProvider) {
    // 1. State Loading
    if (studentProvider.isLoading) {
      return _buildLoadingState();
    }

    // 2. State Error
    if (studentProvider.error != null) {
      return _buildErrorState(studentProvider.error!);
    }

    final scheduleByDay = studentProvider.scheduleByDay;

    // 3. State Data Kosong
    if (scheduleByDay.isEmpty) {
      return _buildEmptyState();
    }

    // 4. State Sukses: Tampilkan data
    return _buildScheduleContent(scheduleByDay);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColorTheme.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColorTheme.blueShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColorTheme.primary,
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat jadwal...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColorTheme.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom:
            MediaQuery.of(context).padding.bottom + 100, // Added bottom padding
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColorTheme.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColorTheme.destructive.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorTheme.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColorTheme.destructive,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorTheme.mutedForeground,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColorTheme.primaryLinearGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorTheme.blueShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _fetchSchedule,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Coba Lagi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColorTheme.primaryForeground,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom:
            MediaQuery.of(context).padding.bottom + 100, // Added bottom padding
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColorTheme.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColorTheme.blueShadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColorTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 64,
                  color: AppColorTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Jadwal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Jadwal pelajaran Anda akan muncul di sini ketika tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColorTheme.mutedForeground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(Map<String, dynamic> scheduleByDay) {
    final days = scheduleByDay.keys.toList();

    return DefaultTabController(
      length: days.length,
      child: Column(
        children: [
          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorTheme.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColorTheme.blueShadow,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                gradient: AppColorTheme.primaryLinearGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColorTheme.blueShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColorTheme.primaryForeground,
              unselectedLabelColor: AppColorTheme.mutedForeground,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.all(8),
              tabs:
                  days
                      .map(
                        (day) => Tab(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(day),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              children:
                  days.map((day) {
                    final schedules = scheduleByDay[day]!;
                    return _buildScheduleList(schedules);
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(List<dynamic> schedules) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom +
            100, // Added proper bottom padding
      ),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildScheduleCard(schedule, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleCard(dynamic schedule, int index) {
    final colors = [
      AppColorTheme.blueColors[500]!,
      AppColorTheme.purpleColors[500]!,
      AppColorTheme.blueColors[400]!,
      AppColorTheme.purpleColors[400]!,
    ];

    final cardColor = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Add tap functionality if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Subject Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cardColor, cardColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book_rounded,
                    color: AppColorTheme.primaryForeground,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Schedule Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.subject.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorTheme.foreground,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.teacher.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColorTheme.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cardColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: cardColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${schedule.startTime} - ${schedule.endTime}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cardColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
