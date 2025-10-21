import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';
import 'package:absensi_siswa/models/student_models.dart';
import 'package:absensi_siswa/theme/color_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // PageController untuk carousel
  final PageController _schedulePageController = PageController(
    viewportFraction: 0.85,
  );
  int _currentScheduleIndex = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _schedulePageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.user?['profileData']?['id'];

    if (studentId != null) {
      await Provider.of<StudentProvider>(
        context,
        listen: false,
      ).fetchStudentDashboard(studentId);
    }
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
              Icons.dashboard_rounded,
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
                  'SMAN 1 Pabedilan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.primaryForeground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Dashboard Siswa',
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
          Container(
            decoration: BoxDecoration(
              color: AppColorTheme.glassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: AppColorTheme.destructive,
              ),
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
    );
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

            // Main Content
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

  Widget _buildContent(StudentProvider studentProvider) {
    if (studentProvider.isLoading && studentProvider.dashboard == null) {
      return _buildLoadingState();
    }

    if (studentProvider.error != null) {
      return _buildErrorState(studentProvider.error!);
    }

    if (studentProvider.dashboard == null) {
      return _buildEmptyState();
    }

    final dashboard = studentProvider.dashboard!;
    final student = dashboard.student;

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      color: AppColorTheme.primary,
      backgroundColor: AppColorTheme.cardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.0,
          16.0,
          16.0,
          MediaQuery.of(context).padding.bottom + 120.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(context, student),
            const SizedBox(height: 24),
            _buildSectionTitle('Jadwal Hari Ini', Icons.schedule_rounded),
            _buildTodayScheduleCarousel(dashboard.todaySchedule),
            const SizedBox(height: 24),
            _buildSectionTitle('Nilai Terbaru', Icons.grade_rounded),
            _buildRecentScores(dashboard.recentScores),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayScheduleCarousel(List<Schedule> schedule) {
    if (schedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColorTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColorTheme.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColorTheme.blueShadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorTheme.accent,
                    AppColorTheme.accent.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColorTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.celebration_rounded,
                size: 56,
                color: AppColorTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada jadwal hari ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorTheme.foreground,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Saatnya istirahat dan bersiap untuk hari esok! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorTheme.mutedForeground,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Carousel untuk jadwal
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _schedulePageController,
            onPageChanged: (index) {
              setState(() {
                _currentScheduleIndex = index;
              });
            },
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              final colors = [
                [
                  AppColorTheme.blueColors[500]!,
                  AppColorTheme.blueColors[400]!,
                ],
                [
                  AppColorTheme.purpleColors[500]!,
                  AppColorTheme.purpleColors[400]!,
                ],
                [
                  AppColorTheme.blueColors[600]!,
                  AppColorTheme.blueColors[500]!,
                ],
                [
                  AppColorTheme.purpleColors[600]!,
                  AppColorTheme.purpleColors[500]!,
                ],
              ];
              final gradientColors = colors[index % colors.length];
              final isActive = index == _currentScheduleIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isActive ? 0 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(
                        alpha: isActive ? 0.4 : 0.2,
                      ),
                      blurRadius: isActive ? 20 : 10,
                      offset: Offset(0, isActive ? 12 : 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      // Animate to this page if not already active
                      if (!isActive) {
                        _schedulePageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan nomor urut dan waktu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorTheme.primaryForeground
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColorTheme.primaryForeground
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Jam ke-${index + 1}',
                                  style: TextStyle(
                                    color: AppColorTheme.primaryForeground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorTheme.primaryForeground
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: AppColorTheme.primaryForeground,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.startTime} - ${item.endTime}',
                                      style: TextStyle(
                                        color: AppColorTheme.primaryForeground,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Subject name
                          Text(
                            item.subject.name,
                            style: TextStyle(
                              color: AppColorTheme.primaryForeground,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),

                          // Teacher info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColorTheme.primaryForeground
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColorTheme.primaryForeground,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.teacher.name,
                                  style: TextStyle(
                                    color: AppColorTheme.primaryForeground
                                        .withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Dots indicator
        if (schedule.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              schedule.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentScheduleIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentScheduleIndex == index
                          ? AppColorTheme.primary
                          : AppColorTheme.mutedForeground.withValues(
                            alpha: 0.3,
                          ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Rest of the methods remain the same...
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
                  'Memuat dashboard...',
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
      padding: const EdgeInsets.all(24.0),
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
                  onPressed: _fetchDashboardData,
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
      padding: const EdgeInsets.all(24.0),
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
                  Icons.dashboard_outlined,
                  size: 64,
                  color: AppColorTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Data Tidak Tersedia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Data dashboard Anda akan muncul di sini ketika tersedia',
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueShadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColorTheme.primaryLinearGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColorTheme.primaryForeground, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorTheme.foreground,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScores(List<Score> scores) {
    if (scores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48), // Increased from 32
        decoration: BoxDecoration(
          color: AppColorTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColorTheme.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColorTheme.blueShadow.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24), // Increased from 16
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorTheme.accent,
                    AppColorTheme.accent.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20), // Increased from 16
                boxShadow: [
                  BoxShadow(
                    color: AppColorTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.grade_outlined,
                size: 64, // Increased from 48
                color: AppColorTheme.primary,
              ),
            ),
            const SizedBox(height: 32), // Increased from 16
            Text(
              'Belum ada nilai',
              style: TextStyle(
                fontSize: 22, // Increased from 18
                fontWeight: FontWeight.bold,
                color: AppColorTheme.foreground,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16), // Increased from 8
            Text(
              'Nilai terbaru akan muncul di sini ketika sudah tersedia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorTheme.mutedForeground,
                fontSize: 16, // Added explicit font size
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24), // Added extra spacing at bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColorTheme.accent.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColorTheme.glassBorder, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColorTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tunggu update dari guru',
                    style: TextStyle(
                      color: AppColorTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueShadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scores.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final score = scores[index];
          final isGoodScore = score.value >= 75;
          final scoreColor =
              isGoodScore ? AppColorTheme.success : AppColorTheme.destructive;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  index == 0
                      ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )
                      : index == scores.length - 1
                      ? const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )
                      : null,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scoreColor,
                            scoreColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: scoreColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          score.value.toInt().toString(),
                          style: TextStyle(
                            color: AppColorTheme.primaryForeground,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            score.subject.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColorTheme.foreground,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tipe: ${score.type}',
                            style: TextStyle(
                              color: AppColorTheme.mutedForeground,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorTheme.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat(
                                'd MMM yyyy',
                              ).format(score.createdAt ?? DateTime.now()),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColorTheme.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              color: AppColorTheme.glassBorder,
              indent: 88,
            ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, Student student) {
    return Card(
      elevation: 4,
      shadowColor: AppColorTheme.blueShadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: AppColorTheme.primaryLinearGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColorTheme.primaryForeground.withOpacity(
                    0.9,
                  ),
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColorTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColorTheme.primaryForeground,
                        ),
                        maxLines: 1, // FIXED: Prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        student.userInfo.email,
                        style: TextStyle(
                          color: AppColorTheme.primaryForeground.withOpacity(
                            0.8,
                          ),
                        ),
                        maxLines: 1, // FIXED: Prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColorTheme.primaryForeground.withOpacity(0.3)),
            const SizedBox(height: 4),
            _buildInfoRow(
              'NIS',
              student.nis,
              color: AppColorTheme.primaryForeground,
            ),
            _buildInfoRow(
              'Kelas',
              student.classInfo.name,
              color: AppColorTheme.primaryForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color color = AppColorTheme.foreground,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.8))),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.end,
              maxLines: 1, // FIXED: Prevent overflow
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColorTheme.mutedForeground),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: AppColorTheme.destructive),
                ),
              ),
            ],
          ),
    );
  }
}
