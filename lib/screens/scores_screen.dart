import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/providers/auth_providers.dart';
import 'package:absensi_siswa/providers/student_provider.dart';
import '../models/student_models.dart';
import 'package:absensi_siswa/theme/color_theme.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'SEMUA';
  final List<String> _filterOptions = ['SEMUA', 'UTS', 'UAS', 'TUGAS'];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch scores with animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchScores();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchScores() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.user?['profileData']?['id'];

    if (studentId != null) {
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).fetchStudentScores(studentId);
    } else {
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).setError("ID Siswa tidak ditemukan. Silakan login ulang.");
    }
  }

  List<Score> _getFilteredScores(List<Score> scores) {
    if (_selectedFilter == 'SEMUA') return scores;
    return scores.where((score) => score.type == _selectedFilter).toList();
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
            // Custom App Bar with gradient - konsisten dengan ScheduleScreen
            _buildCustomAppBar(),

            // Filter Section
            _buildFilterSection(),

            // Main Content
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, studentProvider, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildScoresContent(studentProvider),
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
              Icons.grade_rounded,
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
                  'Daftar Nilai',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.primaryForeground,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Pantau perkembangan akademik Anda',
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
      child: Row(
        children:
            _filterOptions.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColorTheme.blueColors[500]!,
                                  AppColorTheme.blueColors[600]!,
                                ],
                              )
                              : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColorTheme.blueShadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      filter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isSelected
                                ? AppColorTheme.primaryForeground
                                : AppColorTheme.mutedForeground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildScoresContent(StudentProvider studentProvider) {
    if (studentProvider.isLoading) {
      return _buildLoadingState();
    }

    if (studentProvider.error != null) {
      return _buildErrorState(studentProvider.error!);
    }

    final allScores = studentProvider.scores;
    final filteredScores = _getFilteredScores(allScores);

    if (allScores.isEmpty) {
      return _buildEmptyState();
    }

    if (filteredScores.isEmpty && _selectedFilter != 'SEMUA') {
      return _buildNoFilterResults();
    }

    return _buildScoresList(filteredScores, allScores);
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
                    AppColorTheme.blueColors[600]!,
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat nilai...',
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
                  onPressed: _fetchScores,
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorTheme.blueColors[400]!.withValues(alpha: 0.2),
                      AppColorTheme.blueColors[600]!.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.grade_outlined,
                  size: 64,
                  color: AppColorTheme.blueColors[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Nilai',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nilai belum diinput oleh guru.\nSilakan cek kembali nanti.',
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

  Widget _buildNoFilterResults() {
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorTheme.blueColors[500]!.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.filter_list_off_rounded,
                  size: 48,
                  color: AppColorTheme.blueColors[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak Ada Nilai $_selectedFilter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorTheme.foreground,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba pilih filter lain',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColorTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoresList(List<Score> filteredScores, List<Score> allScores) {
    return Column(
      children: [
        // Summary Card
        if (allScores.isNotEmpty) _buildSummaryCard(allScores),

        // Scores List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 100,
            ),
            itemCount: filteredScores.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildScoreCard(
                        context,
                        filteredScores[index],
                        index,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(List<Score> scores) {
    final average =
        scores.isNotEmpty
            ? scores.map((s) => s.value).reduce((a, b) => a + b) / scores.length
            : 0.0;

    final highestScore =
        scores.isNotEmpty
            ? scores.map((s) => s.value).reduce((a, b) => a > b ? a : b)
            : 0.0;

    final lowestScore =
        scores.isNotEmpty
            ? scores.map((s) => s.value).reduce((a, b) => a < b ? a : b)
            : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorTheme.cardBackground,
            AppColorTheme.cardHoverBackground,
          ],
        ),
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
          Text(
            'Ringkasan Nilai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorTheme.foreground,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryItem(
                'Rata-rata',
                average,
                Icons.trending_up_rounded,
                AppColorTheme.blueColors[600]!,
              ),
              _buildSummaryItem(
                'Tertinggi',
                highestScore,
                Icons.arrow_upward_rounded,
                AppColorTheme.success,
              ),
              _buildSummaryItem(
                'Terendah',
                lowestScore,
                Icons.arrow_downward_rounded,
                AppColorTheme.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColorTheme.mutedForeground,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, Score score, int index) {
    // Konsisten dengan ScheduleScreen - menggunakan array warna biru
    final colors = [
      AppColorTheme.blueColors[500]!,
      AppColorTheme.blueColors[600]!,
      AppColorTheme.blueColors[400]!,
      AppColorTheme.blueColors[700]!,
    ];

    final cardColor = colors[index % colors.length];
    final scoreIcon = _getScoreIcon(score.type);
    final formattedDate =
        score.createdAt != null
            ? DateFormat('d MMM yyyy', 'id_ID').format(score.createdAt!)
            : 'Tanggal tidak tersedia';

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
            _showScoreDetail(context, score);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Subject Icon - konsisten dengan ScheduleScreen
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
                    scoreIcon.icon,
                    color: AppColorTheme.primaryForeground,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.subject.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorTheme.foreground,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: cardColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              score.type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cardColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColorTheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorTheme.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Score - dengan styling yang lebih konsisten
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getScoreColor(score.value).withValues(alpha: 0.1),
                        _getScoreColor(score.value).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getScoreColor(score.value).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    score.value.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score.value),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScoreDetail(BuildContext context, Score score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColorTheme.cardBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: AppColorTheme.glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColorTheme.blueShadow,
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorTheme.mutedForeground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Detail Nilai',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorTheme.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailItem('Mata Pelajaran', score.subject.name),
                _buildDetailItem('Jenis Penilaian', score.type),
                _buildDetailItem('Nilai', score.value.toStringAsFixed(1)),
                _buildDetailItem(
                  'Tanggal',
                  score.createdAt != null
                      ? DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(score.createdAt!)
                      : 'Tidak tersedia',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColorTheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColorTheme.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double value) {
    if (value >= 85) return AppColorTheme.success;
    if (value >= 75) return AppColorTheme.primary;
    if (value >= 65) return AppColorTheme.warning;
    return AppColorTheme.error;
  }

  ({IconData icon, Color color}) _getScoreIcon(String type) {
    switch (type.toUpperCase()) {
      case 'UTS':
        return (
          icon: Icons.quiz_rounded,
          color: AppColorTheme.blueColors[600]!,
        );
      case 'UAS':
        return (
          icon: Icons.school_rounded,
          color: AppColorTheme.purpleColors[600]!,
        );
      case 'TUGAS':
        return (
          icon: Icons.assignment_rounded,
          color: AppColorTheme.blueColors[500]!,
        );
      default:
        return (
          icon: Icons.grade_rounded,
          color: AppColorTheme.mutedForeground,
        );
    }
  }
}
