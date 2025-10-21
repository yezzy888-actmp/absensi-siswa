import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Pastikan path import ini sesuai dengan struktur proyek Anda
import 'package:absensi_siswa/screens/dashboard_screen.dart';
import 'package:absensi_siswa/screens/schedule_screen.dart';
import 'package:absensi_siswa/screens/profile_screen.dart';
import 'package:absensi_siswa/screens/scores_screen.dart';
import 'package:absensi_siswa/theme/color_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _navAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ScheduleScreen(),
    ScoresScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFABPressed() {
    HapticFeedback.mediumImpact();
    _fabAnimationController.reverse().then((_) {
      _fabAnimationController.forward();
    });
    Navigator.pushNamed(context, '/attendance');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: RotationTransition(
          turns: _fabRotationAnimation,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColorTheme.primary,
                  AppColorTheme.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(36),
                onTap: _onFABPressed,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedBuilder(
        animation: _navAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              150 *
                  (1 - Curves.easeOut.transform(_navAnimationController.value)),
            ),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Beranda',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Jadwal',
                      index: 1,
                    ),
                    const SizedBox(width: 40),
                    _buildNavItem(
                      icon: Icons.grade_rounded,
                      label: 'Nilai',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- PERUBAHAN FINAL ADA DI SINI ---
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _onItemTapped(index);
        },
        behavior: HitTestBehavior.opaque,
        // DIBUNGKUS DENGAN CENTER
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Penting: agar Column sekecil kontennya
            // mainAxisAlignment: MainAxisAlignment.center, // Tidak perlu, sudah di-handle oleh Center
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? AppColorTheme.primary
                        : AppColorTheme.mutedForeground,
                size: 24,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected
                          ? AppColorTheme.primary
                          : AppColorTheme.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
