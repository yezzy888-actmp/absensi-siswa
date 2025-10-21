// lib/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';
import 'package:absensi_siswa/theme/color_theme.dart';
import '../models/student_models.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with TickerProviderStateMixin {
  String? _selectedStatus;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
      _fetchHistory();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchHistory({String? status}) {
    final studentId =
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).user?['profileData']?['id'];
    if (studentId != null) {
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).fetchAttendanceHistory(studentId, status: status);
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
            _buildCustomAppBar(),
            _buildFilterSection(),
            Expanded(child: _buildAttendanceList()),
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
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColorTheme.blueColors[600],
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorTheme.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            ),
            child: Icon(
              Icons.history_rounded,
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
                  'Riwayat Absensi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.primaryForeground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Lihat history kehadiran Anda',
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

  Widget _buildFilterSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColorTheme.primaryLinearGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorTheme.blueShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: AppColorTheme.primaryForeground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColorTheme.foreground,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children:
                      ['HADIR', 'IZIN', 'SAKIT', 'ALPHA'].asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final status = entry.value;
                        final isSelected = _selectedStatus == status;
                        final statusInfo = _getStatusInfo(status, index);

                        return Container(
                          margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedStatus = null;
                                  } else {
                                    _selectedStatus = status;
                                  }
                                });
                                _fetchHistory(status: _selectedStatus);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      isSelected
                                          ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              statusInfo.color,
                                              statusInfo.color.withValues(
                                                alpha: 0.8,
                                              ),
                                            ],
                                          )
                                          : null,
                                  color:
                                      isSelected
                                          ? null
                                          : statusInfo.color.withValues(
                                            alpha: 0.1,
                                          ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? statusInfo.color
                                            : statusInfo.color.withValues(
                                              alpha: 0.3,
                                            ),
                                    width: 1.5,
                                  ),
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: statusInfo.color
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                          : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusInfo.icon,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : statusInfo.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : statusInfo.color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }
        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }
        if (provider.attendanceHistory.isEmpty) {
          return _buildEmptyState();
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(context).padding.bottom + 100,
            ),
            itemCount: provider.attendanceHistory.length,
            itemBuilder: (context, index) {
              final attendance = provider.attendanceHistory[index];
              return _buildAttendanceCard(attendance, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard(Attendance attendance, int index) {
    // Menggunakan sistem warna seperti schedule screen
    final colors = [
      AppColorTheme.blueColors[500]!,
      AppColorTheme.purpleColors[500]!,
      AppColorTheme.blueColors[400]!,
      AppColorTheme.purpleColors[400]!,
    ];

    final cardColor = colors[index % colors.length];
    final statusInfo = _getStatusInfo(attendance.status, index);
    final localDate = attendance.date.toLocal();

    final formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(localDate);
    final formattedTime = DateFormat('HH:mm', 'id_ID').format(localDate);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                        // Subject Icon dengan warna konsisten
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cardColor,
                                cardColor.withValues(alpha: 0.8),
                              ],
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

                        // Attendance Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attendance.schedule.subject.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorTheme.foreground,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColorTheme.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColorTheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Status Badge dengan warna yang disesuaikan
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusInfo.color,
                                statusInfo.color.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: statusInfo.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusInfo.icon,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                attendance.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
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
            ),
          ),
        );
      },
    );
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
                  'Memuat riwayat absensi...',
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
                  onPressed: () => _fetchHistory(status: _selectedStatus),
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
                  color: AppColorTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: AppColorTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _selectedStatus != null
                    ? 'Tidak Ada Data'
                    : 'Belum Ada Riwayat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedStatus != null
                    ? 'Tidak ada riwayat absensi dengan status $_selectedStatus'
                    : 'Riwayat absensi Anda akan muncul di sini',
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

  ({Color color, IconData icon}) _getStatusInfo(String status, int index) {
    // Menggunakan skema warna biru yang konsisten
    final colors = [
      AppColorTheme.blueColors[500]!, // HADIR - Biru primary
      AppColorTheme.blueColors[400]!, // IZIN - Biru lebih terang
      AppColorTheme.purpleColors[500]!, // SAKIT - Ungu
      AppColorTheme.purpleColors[400]!, // ALPHA - Ungu lebih terang
    ];

    switch (status) {
      case 'HADIR':
        return (
          color: AppColorTheme.blueColors[500]!,
          icon: Icons.check_circle_rounded,
        );
      case 'IZIN':
        return (
          color: AppColorTheme.blueColors[400]!,
          icon: Icons.mail_rounded,
        );
      case 'SAKIT':
        return (
          color: AppColorTheme.purpleColors[500]!,
          icon: Icons.sick_rounded,
        );
      case 'ALPHA':
        return (
          color: AppColorTheme.purpleColors[400]!,
          icon: Icons.cancel_rounded,
        );
      default:
        return (color: colors[index % colors.length], icon: Icons.help_rounded);
    }
  }
}
