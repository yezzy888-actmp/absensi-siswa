// lib/screens/attendance_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';
import 'package:absensi_siswa/theme/color_theme.dart';
import 'package:absensi_siswa/utils/qr_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  final TextEditingController _tokenController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  bool _isFlashOn = false;
  DateTime? _lastScanTime;
  static const Duration _scanCooldown = Duration(seconds: 3);

  late AnimationController _animationController;
  late Animation<double> _scannerAnimation;
  late AnimationController _pulseController;

  // State untuk menyimpan lokasi terakhir yang sukses diproses
  double? _lastScannedLatitude;
  double? _lastScannedLongitude;
  String? _lastSuccessMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _scannerController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Method untuk mengecek apakah masih dalam cooldown
  bool _isInCooldown() {
    if (_lastScanTime == null) return false;
    return DateTime.now().difference(_lastScanTime!) < _scanCooldown;
  }

  // Method untuk menampilkan countdown cooldown
  void _showCooldownMessage() {
    final remainingTime =
        _scanCooldown.inSeconds -
        DateTime.now().difference(_lastScanTime!).inSeconds;
    _showFeedback('Tunggu ${remainingTime}s sebelum scan lagi', isError: false);
    print(
      'W/AttendanceScreen: Scan cooldown active. Remaining: ${remainingTime}s',
    );
  }

  // Handle successful submission to update UI state
  void _handleSuccess(String message, double? lat, double? lon) {
    if (!mounted) return;
    print(
      'I/AttendanceScreen: Absensi Success. Lat: $lat, Lon: $lon. Message: $message',
    );
    setState(() {
      _lastScannedLatitude = lat;
      _lastScannedLongitude = lon;
      _lastSuccessMessage = message;
    });
    _showFeedback(message, isError: false);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        print('I/AttendanceScreen: Navigating back to /main screen...');
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    });
  }

  Future<void> _submitAttendance(String? rawQRData) async {
    print(
      'I/AttendanceScreen: Starting attendance submission for data: $rawQRData',
    );

    if (rawQRData == null || rawQRData.isEmpty) {
      _showFeedback('Token tidak boleh kosong.', isError: true);
      print('E/AttendanceScreen: Submission stopped. QR Data is empty/null.');
      return;
    }

    if (_isInCooldown()) {
      _showCooldownMessage();
      return;
    }

    if (_isProcessing) return;

    _lastScanTime = DateTime.now();
    HapticFeedback.lightImpact();

    setState(() {
      _isProcessing = true;
      _lastSuccessMessage = null; // Clear previous success message
    });

    final Map<String, dynamic>? qrData = QRDataProcessor.parseQRData(rawQRData);

    if (qrData == null || !QRDataProcessor.isValidAttendanceQR(qrData)) {
      _showFeedback(
        'Format QR Code tidak valid atau bukan untuk absensi.',
        isError: true,
      );
      print('E/AttendanceScreen: Invalid QR format or not an attendance QR.');
      setState(() => _isProcessing = false);
      return;
    }

    print(
      'I/AttendanceScreen: QR Data parsed successfully. Token: ${qrData['token']}',
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.user?['profileData']?['id'];

    if (studentId == null) {
      _showFeedback(
        'Gagal mendapatkan data siswa. Silakan login ulang.',
        isError: true,
      );
      print(
        'E/AttendanceScreen: Student ID is null. User might not be logged in correctly.',
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    double? currentLat;
    double? currentLon;

    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );

    // --- LOCATION ACQUISITION ---
    print('I/AttendanceScreen: Starting location acquisition...');
    try {
      final status = await Permission.locationWhenInUse.request();
      if (status == PermissionStatus.granted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        currentLat = position.latitude;
        currentLon = position.longitude;
        print(
          'I/AttendanceScreen: Location acquired successfully. Lat: $currentLat, Lon: $currentLon',
        );
      } else {
        // Lokasi tidak didapat/izin ditolak, kirim null
        _showFeedback(
          'Lokasi tidak tersedia untuk presensi ini.',
          isError: false,
        );
        print(
          'W/AttendanceScreen: Location permission denied or not granted. Sending null coordinates.',
        );
      }
    } catch (e) {
      final errorMessage =
          'Gagal mendapatkan lokasi: ${e.toString().split('.')[0]}';
      _showFeedback(errorMessage, isError: true);
      currentLat = null;
      currentLon = null;
      print('E/AttendanceScreen: Failed to get location: $e');
    }

    // --- SUBMIT ATTENDANCE API CALL ---
    print(
      'I/AttendanceScreen: Calling API submitAttendance with Lat: $currentLat, Lon: $currentLon',
    );
    try {
      final result = await studentProvider.submitAttendance(
        studentId,
        qrData['token'].toString(),
        studentLatitude: currentLat, // Kirim lat/lon yang didapat (bisa null)
        studentLongitude: currentLon, // Kirim lat/lon yang didapat (bisa null)
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Panggil handler sukses baru
        final successMessage =
            result['data']?['message'] ?? 'Absensi berhasil!';
        print('I/AttendanceScreen: API Success. Message: $successMessage');
        _handleSuccess(
          successMessage,
          currentLat, // Kirim lat/lon yang didapat
          currentLon, // Kirim lat/lon yang didapat
        );
      } else {
        final errorMessage = result['message'] ?? 'Terjadi kesalahan.';
        final cleanedMessage = errorMessage.replaceFirst('Exception: ', '');
        print(
          'E/AttendanceScreen: API Failed. Error: $cleanedMessage. Full result: $result',
        );
        _showFeedback(cleanedMessage, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      final cleanedError = e.toString().replaceFirst('Exception: ', '');
      print(
        'E/AttendanceScreen: API Call failed with Exception: $cleanedError',
      );
      _showFeedback(cleanedError, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        print(
          'I/AttendanceScreen: Processing finished. _isProcessing set to false.',
        );
      }
    }
  }

  void _showFeedback(String message, {required bool isError}) {
    // ... (implementasi _showFeedback tetap sama, hanya perlu dipastikan tidak menampilkan pesan sukses yang lama)
    if (!mounted) return;
    // Logika: Jika ini pesan success, kita tidak mau menampilkan pesan ini jika _handleSuccess sudah memicu navigasi
    if (!isError &&
        _lastSuccessMessage != null &&
        message == _lastSuccessMessage)
      return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColorTheme.error : AppColorTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleFlash() async {
    // ... (sama seperti sebelumnya)
    try {
      await _scannerController.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      print(
        'I/AttendanceScreen: Flashlight toggled. Current state: $_isFlashOn',
      );
    } catch (e) {
      _showFeedback('Gagal mengatur flash', isError: true);
      print('E/AttendanceScreen: Failed to toggle flashlight: $e');
    }
  }

  void _switchCamera() async {
    // ... (sama seperti sebelumnya)
    try {
      await _scannerController.switchCamera();
      print('I/AttendanceScreen: Camera switched.');
    } catch (e) {
      _showFeedback('Gagal beralih kamera', isError: true);
      print('E/AttendanceScreen: Failed to switch camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorTheme.glassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorTheme.glassBorder, width: 1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColorTheme.foreground,
              size: 20,
            ),
            onPressed: () {
              print('I/AttendanceScreen: Back button pressed.');
              Navigator.pop(context);
            },
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColorTheme.glassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColorTheme.glassBorder, width: 1),
          ),
          child: const Text(
            'Scan QR Absensi',
            style: TextStyle(
              color: AppColorTheme.foreground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColorTheme.glassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      key: ValueKey(_isFlashOn),
                      color:
                          _isFlashOn
                              ? AppColorTheme.warning
                              : AppColorTheme.mutedForeground,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Toggle Flash',
                  onPressed: _toggleFlash,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: AppColorTheme.mutedForeground,
                    size: 20,
                  ),
                  tooltip: 'Switch Camera',
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColorTheme.backgroundLinearGradient,
        ),
        child: Stack(
          children: [
            // Scanner Area
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  if (_isProcessing || _isInCooldown()) {
                    if (_isInCooldown()) {
                      print(
                        'W/AttendanceScreen: Scanner detected but cooldown is active.',
                      );
                    } else if (_isProcessing) {
                      print(
                        'W/AttendanceScreen: Scanner detected but already processing.',
                      );
                    }
                    return;
                  }
                  final String? scannedToken = capture.barcodes.first.rawValue;
                  print(
                    'I/AttendanceScreen: QR Code scanned. Raw value: $scannedToken',
                  );
                  _submitAttendance(scannedToken);
                },
              ),
            ),

            // Scanner Overlay
            _buildScannerOverlay(context),

            // [ADDED] Lokasi Indikator (muncul setelah sukses)
            if (_lastScannedLatitude != null &&
                _lastSuccessMessage != null &&
                !_isProcessing)
              _buildLocationIndicator(context),

            // Bottom Section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSection(),
            ),

            // Processing Overlay
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanArea = size.width * 0.65;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Instruction Text (Hidden jika sukses dan menampilkan lokasi)
          if (_lastSuccessMessage == null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColorTheme.glassBackground,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColorTheme.glassBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColorTheme.blueShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColorTheme.primaryLinearGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Arahkan kamera ke QR Code',
                    style: TextStyle(
                      color: AppColorTheme.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 40),

          // Animated Scanner Frame (Hidden jika sukses dan menampilkan lokasi)
          if (_lastSuccessMessage == null)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: scanArea + (_pulseController.value * 20),
                  height: scanArea + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColorTheme.primary.withOpacity(0.8),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorTheme.primary.withOpacity(0.3),
                        blurRadius: 20 + (_pulseController.value * 10),
                        spreadRadius: 2 + (_pulseController.value * 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Corner indicators
                      ...List.generate(4, (index) {
                        return Positioned(
                          top: index < 2 ? 16 : null,
                          bottom: index >= 2 ? 16 : null,
                          left: index % 2 == 0 ? 16 : null,
                          right: index % 2 == 1 ? 16 : null,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: AppColorTheme.primaryLinearGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }),

                      // Scanning line
                      AnimatedBuilder(
                        animation: _scannerAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top:
                                20 +
                                (_scannerAnimation.value * (scanArea - 60)),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColorTheme.accent,
                                    AppColorTheme.primary,
                                    AppColorTheme.accent,
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 40),
          // Placeholder spacing if scanner overlay is hidden
          if (_lastSuccessMessage != null) SizedBox(height: scanArea * 0.3),
        ],
      ),
    );
  }

  // NEW WIDGET: Menampilkan lokasi setelah sukses
  Widget _buildLocationIndicator(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColorTheme.success.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            const Text(
              "Lokasi Terkirim!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Lat: ${_lastScannedLatitude!.toStringAsFixed(5)}\nLon: ${_lastScannedLongitude!.toStringAsFixed(5)}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              _lastSuccessMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColorTheme.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(color: AppColorTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Opsi Alternatif
          const Text(
            'Punya Kendala Scan?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColorTheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gunakan metode alternatif di bawah ini.',
            style: TextStyle(
              fontSize: 14,
              color: AppColorTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          // Tombol Input Manual
          _buildAlternativeButton(
            icon: Icons.keyboard_alt_outlined,
            label: 'Input Manual',
            onTap: () {
              if (!_isProcessing) {
                print('I/AttendanceScreen: Manual input button pressed.');
                _showManualInputSheet(context);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAlternativeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColorTheme.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColorTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColorTheme.mutedForeground, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColorTheme.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualInputSheet(BuildContext context) {
    // Panggil _submitAttendance dengan nilai null untuk lat/lon saat input manual
    // agar backend yang menangani.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColorTheme.cardBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Input Token Manual',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan token yang Anda dapatkan untuk melakukan absensi.',
                  style: TextStyle(
                    color: AppColorTheme.mutedForeground,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                _buildManualInputSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColorTheme.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColorTheme.border, width: 1),
          ),
          child: TextField(
            controller: _tokenController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColorTheme.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'KODE-TOKEN',
              hintStyle: TextStyle(
                color: AppColorTheme.inputPlaceholder,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColorTheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColorTheme.primaryLinearGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColorTheme.blueShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                final token = _tokenController.text;
                Navigator.pop(context);
                print(
                  'I/AttendanceScreen: Manual token submitted: $token. Starting submission...',
                );
                _submitAttendance(token); // Panggil dengan lat/lon null
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Kirim Absensi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColorTheme.primaryLinearGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Memproses Absensi...',
                  style: TextStyle(
                    color: AppColorTheme.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar',
                  style: TextStyle(
                    color: AppColorTheme.mutedForeground,
                    fontSize: 14,
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
