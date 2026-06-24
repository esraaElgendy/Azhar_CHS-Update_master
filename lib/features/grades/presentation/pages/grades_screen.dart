import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/grades_cubit.dart';
import '../../../../core/models/grades_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGrades();
    });
  }

  void _fetchGrades() {
    final lang = Localizations.localeOf(context).languageCode;
    context.read<GradesCubit>().fetchGrades(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: BlocBuilder<GradesCubit, GradesState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _fetchGrades();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTypography.spacingL,
                          vertical: AppTypography.spacingXL,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildHeader(context),
                            const SizedBox(height: AppTypography.spacing3XL),
                            if (state is GradesLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (state is GradesError)
                              _buildErrorState(state.message, l10n)
                            else if (state is GradesLoaded) ...[
                              _buildPerformanceCard(isDark, state.summary),
                              const SizedBox(height: AppTypography.spacing3XL),
                              _buildSubjectGradesHeader(l10n),
                              const SizedBox(height: AppTypography.spacingL),
                              if (state.summary.semesterGrades.isEmpty)
                                _buildEmptyState(context)
                              else
                                _buildTermsList(
                                  state.summary.semesterGrades,
                                  isDark,
                                  l10n,
                                ),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: AppTypography.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.myGrades,
                style: AppTypography.headingM.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppTypography.spacingXS),
              Text('Student Portal', style: AppTypography.bodyMSubtle()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchGrades, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Text(
          Localizations.localeOf(context).languageCode == 'ar' 
              ? 'لا توجد درجات متاحة' 
              : 'No grades available',
          style: AppTypography.bodyMSubtle(),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(bool isDark, GradesSummaryModel summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTypography.spacingXL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppTypography.radius3XL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Academic\nPerformance',
                  style: AppTypography.headingM.copyWith(
                    color: AppColors.primaryDark,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTypography.spacingM,
                  vertical: AppTypography.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppTypography.radiusXL),
                ),
                child: Text(
                  'SUMMARY',
                  style: AppTypography.badgeL.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTypography.spacingXXL),
          Row(
            children: [
              Expanded(
                child: _performanceStat(
                  label: 'GPA',
                  value: summary.gpa.toStringAsFixed(2),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppTypography.spacingM),
              Expanded(
                child: _performanceStat(
                  label: 'Overall',
                  value: summary.overallLetter.isNotEmpty
                      ? summary.overallLetter
                      : '-',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTypography.spacingM),
          Row(
            children: [
              Expanded(
                child: _performanceStat(
                  label: 'Score',
                  value: '${summary.totalPercentage.toStringAsFixed(1)}%',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppTypography.spacingM),
              Expanded(
                child: _performanceStat(
                  label: 'Points',
                  value: summary.totalGradePoints.toStringAsFixed(1),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceStat({
    required String label,
    required String value,
    String? subLabel,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTypography.spacingM,
        vertical: AppTypography.spacingM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xffF6F7FF),
        borderRadius: BorderRadius.circular(AppTypography.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.captionMMuted()),
          const SizedBox(height: AppTypography.spacingXS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.statisticL.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(width: AppTypography.spacingXS),
                Text(subLabel, style: AppTypography.captionMMuted()),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGradesHeader(AppLocalizations l10n) {
    return Text(
      'Subject Grades',
      style: AppTypography.headingS.copyWith(color: AppColors.primaryDark),
    );
  }

  Widget _buildTermsList(
    List<SemesterGradesModel> semesters,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      children: semesters.map((semester) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppTypography.spacingL),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppTypography.radius2XL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                semester.term,
                style: AppTypography.subheadingL.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    children: semester.courses.map((course) {
                      return _buildCourseGradeCard(course, isDark, l10n);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCourseGradeCard(
    CourseGradeModel course,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final gradeColor = _getGradeColor(course.letterGrade);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              course.letterGrade,
              style: AppTypography.headingS.copyWith(color: gradeColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: AppTypography.subheadingL.copyWith(
                    color: isDark ? Colors.white : AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      course.courseID,
                      isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                    if (course.status.isNotEmpty)
                      _buildInfoChip(
                        course.status,
                        isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                        isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      'Sem ${course.semester}',
                      isDark ? const Color(0xFF134E4A) : const Color(0xFFF0FDFA),
                      isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
                    ),
                    _buildInfoChip(
                      course.academicYear,
                      isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                      isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${course.numericGrade}',
                style: AppTypography.headingM.copyWith(
                  color: gradeColor,
                ),
              ),
              const SizedBox(height: 6),
              _buildInfoChip(
                '${course.percentage}%',
                gradeColor.withValues(alpha: 0.15),
                gradeColor,
              ),
              const SizedBox(height: 6),
              _buildInfoChip(
                '${course.gradePoints} pts',
                isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTypography.captionM.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith("A")) return const Color(0xFF10B981); // Green
    if (grade.startsWith("B")) return const Color(0xFF3B82F6); // Blue
    if (grade.startsWith("C")) return const Color(0xFFF59E0B); // Amber
    if (grade.startsWith("D")) return const Color(0xFFF97316); // Orange
    return const Color(0xFFEF4444); // Red/F
  }
}
