import 'package:absensi_siswa/screens/attendance_history_screen.dart';
import 'package:absensi_siswa/screens/attendance_screen.dart';
import 'package:absensi_siswa/screens/attendance_summary_screen.dart';
import 'package:absensi_siswa/screens/edit_profile_screen.dart';
import 'package:absensi_siswa/screens/scores_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:absensi_siswa/theme/color_theme.dart'; // Import theme

// Provider
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => StudentProvider()),
      ],
      child: MaterialApp(
        title: 'Absensi Siswa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/main': (context) => const MainScreen(),
          '/attendance': (context) => const AttendanceScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/attendance-history': (context) => const AttendanceHistoryScreen(),
          '/attendance-summary': (context) => const AttendanceSummaryScreen(),
          '/scores': (context) => const ScoresScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    // Fade animation untuk logo dan teks
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Scale animation untuk logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation untuk teks
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _slideController.forward();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu minimal 3 detik untuk splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (mounted) {
      if (authProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColorTheme.backgroundLinearGradient,
        ),
        child: Stack(
          children: [
            // Background glow effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      AppColorTheme.blueColors[500]!.withOpacity(0.1),
                      AppColorTheme.blueColors[300]!.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Animated floating elements
            ...List.generate(6, (index) => _buildFloatingElement(index)),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo dengan animasi
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorTheme.blueColors[500]!
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColorTheme.blueColors[500]!,
                                    width: 3,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback jika logo tidak ditemukan
                                    return Icon(
                                      Icons.school,
                                      size: 80,
                                      color: AppColorTheme.blueColors[600],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Nama sekolah dengan animasi slide
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback:
                                (bounds) => AppColorTheme.heroTextLinearGradient
                                    .createShader(bounds),
                            child: const Text(
                              'SMAN 1 PABEDILAN',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistem Absensi Siswa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColorTheme.blueColors[700],
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading indicator dengan animasi
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorTheme.blueColors[500]!
                                    .withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColorTheme.blueColors[600]!,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat aplikasi...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColorTheme.blueColors[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer dengan versi atau copyright
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Versi 1.0.0 • © 2025 SMAN 1 Pabedilan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorTheme.blueColors[600]!.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final size = [20.0, 15.0, 25.0, 18.0, 22.0, 16.0][index];
    final duration = [3000, 4000, 3500, 4500, 3200, 3800][index];

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: duration),
          builder: (context, value, child) {
            return Positioned(
              left:
                  MediaQuery.of(context).size.width *
                  ([0.1, 0.8, 0.2, 0.9, 0.15, 0.85][index]),
              top:
                  MediaQuery.of(context).size.height *
                      ([0.2, 0.3, 0.7, 0.6, 0.8, 0.4][index]) +
                  (30 * (value * 2 - 1).abs()),
              child: Opacity(
                opacity: 0.6 * _fadeAnimation.value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColorTheme.blueColors[300]!.withOpacity(0.6),
                        AppColorTheme.blueColors[500]!.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorTheme.blueColors[400]!.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
