// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/theme/color_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan data dari AuthProvider sebagai sumber utama info user
    final student = Provider.of<AuthProvider>(context).user?['profileData'];
    final email = Provider.of<AuthProvider>(context).user?['email'];

    if (student == null) {
      return Scaffold(
        backgroundColor: AppColorTheme.background,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColorTheme.backgroundLinearGradient,
          ),
          child: _buildErrorState(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColorTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColorTheme.backgroundLinearGradient,
        ),
        child: Column(
          children: [
            // Custom App Bar with blue gradient
            _buildCustomAppBar(context),

            // Main Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildProfileContent(context, student, email),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
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
              Icons.person_rounded,
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
                  'Profil Siswa',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.primaryForeground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Informasi pribadi & akademik',
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
                Icons.edit_outlined,
                color: AppColorTheme.blueColors[600],
                size: 20,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    dynamic student,
    String? email,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header with enhanced design
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedProfileHeader(context, student, email),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Academic Information Section
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        'Informasi Akademik',
                        Icons.school_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedInfoCard(context, student),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Activities & Reports Section
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        'Aktivitas & Laporan',
                        Icons.analytics_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedActionMenu(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProfileHeader(
    BuildContext context,
    dynamic student,
    String? email,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorTheme.blueColors[400]!,
                          AppColorTheme.blueColors[600]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColorTheme.blueColors[500]!.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        student['name']?[0].toUpperCase() ?? 'S',
                        style: const TextStyle(
                          fontSize: 36,
                          color: AppColorTheme.primaryForeground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColorTheme.blueColors[500],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColorTheme.cardBackground,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorTheme.blueColors[500]!.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: AppColorTheme.primaryForeground,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] ?? 'Siswa',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColorTheme.foreground,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColorTheme.blueColors[500]!.withValues(
                              alpha: 0.1,
                            ),
                            AppColorTheme.blueColors[400]!.withValues(
                              alpha: 0.1,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColorTheme.blueColors[500]!.withValues(
                            alpha: 0.2,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 16,
                            color: AppColorTheme.blueColors[600],
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColorTheme.blueColors[700],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorTheme.blueColors[500]!,
                  AppColorTheme.blueColors[600]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColorTheme.primaryForeground, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColorTheme.foreground,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoCard(BuildContext context, dynamic student) {
    final infoItems = [
      {
        'icon': Icons.badge_outlined,
        'label': 'NIS',
        'value': student['nis'] ?? '-',
        'color': AppColorTheme.blueColors[500]!,
      },
      {
        'icon': Icons.class_outlined,
        'label': 'Kelas',
        'value': student['class']?['name'] ?? '-',
        'color': AppColorTheme.blueColors[600]!,
      },
      {
        'icon': Icons.wc_outlined,
        'label': 'Jenis Kelamin',
        'value': student['gender'] ?? '-',
        'color': AppColorTheme.blueColors[400]!,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children:
              infoItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(20 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: _buildEnhancedInfoRow(
                              item['icon'] as IconData,
                              item['label'] as String,
                              item['value'] as String,
                              item['color'] as Color,
                            ),
                          ),
                        );
                      },
                    ),
                    if (index < infoItems.length - 1) ...[
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                    ],
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withValues(alpha: 0.1),
                iconColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColorTheme.mutedForeground,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: iconColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColorTheme.blueColors[200]!.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedActionMenu(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.history_edu_outlined,
        'title': 'Riwayat Absensi',
        'subtitle': 'Lihat semua catatan kehadiran Anda',
        'color': AppColorTheme.blueColors[500]!,
        'route': '/attendance-history',
      },
      {
        'icon': Icons.pie_chart_outline_rounded,
        'title': 'Statistik Absensi',
        'subtitle': 'Lihat rekapitulasi dan grafik',
        'color': AppColorTheme.blueColors[600]!,
        'route': '/attendance-summary',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children:
            menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 500 + (index * 150)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: _buildEnhancedMenuRow(
                            context,
                            icon: item['icon'] as IconData,
                            title: item['title'] as String,
                            subtitle: item['subtitle'] as String,
                            iconColor: item['color'] as Color,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  item['route'] as String,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (index < menuItems.length - 1) _buildDivider(),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildEnhancedMenuRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.1),
                      iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColorTheme.foreground,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColorTheme.mutedForeground,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.1),
                      iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColorTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColorTheme.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.1),
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
                color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 64,
                color: AppColorTheme.blueColors[500],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data Profil Tidak Ditemukan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorTheme.foreground,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silakan login ulang untuk memuat data profil Anda',
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
    );
  }
}
