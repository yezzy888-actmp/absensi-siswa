import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';
import 'package:absensi_siswa/theme/color_theme.dart';
import '../models/student_models.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId =
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).user?['profileData']?['id'];
      if (studentId != null) {
        Provider.of<StudentProvider>(
          context,
          listen: false,
        ).fetchAttendanceSummary(studentId).then((_) {
          if (mounted) {
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            // Custom App Bar dengan konsistensi warna biru
            _buildCustomAppBar(),

            // Main Content
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return _buildLoadingState();
                  }
                  if (provider.error != null) {
                    return _buildErrorState(provider.error!);
                  }
                  if (provider.attendanceSummary == null) {
                    return _buildEmptyState();
                  }

                  final summary = provider.attendanceSummary!;
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildContent(summary),
                        ),
                      );
                    },
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
          // Back Button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorTheme.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColorTheme.blueColors[600],
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Icon dan Title
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorTheme.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            ),
            child: Icon(
              Icons.analytics_rounded,
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
                  'Statistik Absensi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.primaryForeground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Analisis kehadiran Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorTheme.primaryForeground.withOpacity(0.8),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColorTheme.blueColors[500]!,
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  'Memuat statistik absensi...',
                  style: TextStyle(
                    color: AppColorTheme.mutedForeground,
                    fontSize: 16,
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
        bottom: MediaQuery.of(context).padding.bottom + 100,
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
                color: AppColorTheme.destructive.withOpacity(0.1),
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
                  color: AppColorTheme.destructive.withOpacity(0.1),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorTheme.blueColors[500]!,
                      AppColorTheme.blueColors[600]!,
                    ],
                  ),
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
                  onPressed: () {
                    final studentId =
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).user?['profileData']?['id'];
                    if (studentId != null) {
                      Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).fetchAttendanceSummary(studentId);
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
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
        bottom: MediaQuery.of(context).padding.bottom + 100,
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorTheme.blueColors[500]!.withOpacity(0.2),
                      AppColorTheme.blueColors[400]!.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: AppColorTheme.blueColors[500],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Data Statistik',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Data statistik absensi Anda akan muncul di sini ketika tersedia',
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

  Widget _buildContent(AttendanceSummary summary) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 100,
      ),
      children: [
        _buildStatsOverview(summary),
        const SizedBox(height: 24),
        _buildOverallChart(summary),
        const SizedBox(height: 32),
        _buildSectionTitle('Persentase per Mata Pelajaran'),
        const SizedBox(height: 16),
        ...summary.subjectStats.asMap().entries.map(
          (entry) => _buildSubjectStatCard(entry.value, entry.key),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatsOverview(AttendanceSummary summary) {
    final total = summary.statusSummary.values.reduce((a, b) => a + b);
    final hadirCount = summary.statusSummary['HADIR'] ?? 0;
    final attendanceRate = total > 0 ? (hadirCount / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorTheme.blueColors[500]!,
            AppColorTheme.blueColors[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tingkat Kehadiran',
                  style: TextStyle(
                    color: AppColorTheme.primaryForeground.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${attendanceRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColorTheme.primaryForeground,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$hadirCount dari $total pertemuan',
                  style: TextStyle(
                    color: AppColorTheme.primaryForeground.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColorTheme.primaryForeground.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColorTheme.primaryForeground,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColorTheme.foreground,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildOverallChart(AttendanceSummary summary) {
    // Menggunakan warna biru yang konsisten untuk status
    final statusColors = {
      'HADIR': AppColorTheme.blueColors[500]!,
      'IZIN': AppColorTheme.blueColors[400]!,
      'SAKIT': AppColorTheme.blueColors[300]!,
      'ALPHA': AppColorTheme.blueColors[200]!,
    };

    final statusIcons = {
      'HADIR': Icons.check_circle_rounded,
      'IZIN': Icons.info_rounded,
      'SAKIT': Icons.local_hospital_rounded,
      'ALPHA': Icons.cancel_rounded,
    };

    final total = summary.statusSummary.values.reduce((a, b) => a + b);

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColorTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColorTheme.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColorTheme.blueShadow,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Belum ada data absensi.",
            style: TextStyle(
              color: AppColorTheme.mutedForeground,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Kehadiran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColorTheme.foreground,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),

          // Chart dengan animasi
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections:
                          summary.statusSummary.entries.map((entry) {
                            final percentage = (entry.value / total * 100);
                            return PieChartSectionData(
                              color: statusColors[entry.key],
                              value: entry.value.toDouble() * value,
                              title:
                                  percentage >= 5
                                      ? '${percentage.toStringAsFixed(0)}%'
                                      : '',
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                      sectionsSpace: 3,
                      centerSpaceRadius: 60,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.5, // Rasio yang lebih seimbang
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children:
                summary.statusSummary.entries.map((entry) {
                  final percentage = (entry.value / total * 100);
                  return TweenAnimationBuilder<double>(
                    duration: Duration(
                      milliseconds: 800 + (entry.key.hashCode % 4) * 200,
                    ),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColors[entry.key]!.withOpacity(0.1),
                                statusColors[entry.key]!.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: statusColors[entry.key]!.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: statusColors[entry.key]!.withOpacity(
                                    0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  statusIcons[entry.key],
                                  color: statusColors[entry.key],
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ========== PERBAIKAN UTAMA DI SINI ==========
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: statusColors[entry.key],
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ), // sedikit ruang
                                      Text(
                                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          color: AppColorTheme.mutedForeground,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // ============================================
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectStatCard(SubjectAttendanceStats stats, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.foreground.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: AppColorTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stats.subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColorTheme.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPercentageColor(
                    stats.attendancePercentage.toDouble(),
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.attendancePercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getPercentageColor(
                      stats.attendancePercentage.toDouble(),
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            percent: stats.attendancePercentage.toDouble() / 100,
            lineHeight: 8.0,
            barRadius: const Radius.circular(4),
            progressColor: _getPercentageColor(
              stats.attendancePercentage.toDouble(),
            ),
            backgroundColor: AppColorTheme.muted,
            animation: true,
            animationDuration: 1000 + (index * 200),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${stats.total} pertemuan",
                style: const TextStyle(
                  color: AppColorTheme.mutedForeground,
                  fontSize: 12,
                ),
              ),
              Text(
                "Hadir: ${(stats.total * stats.attendancePercentage / 100).round()} kali",
                style: const TextStyle(
                  color: AppColorTheme.mutedForeground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return AppColorTheme.success;
    if (percentage >= 60) return AppColorTheme.warning;
    return AppColorTheme.error;
  }
}
