import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/course_cubit.dart';
import '../../../../core/bloc/course_registration_cubit.dart';
import '../../../../core/bloc/settings_cubit.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import 'course_details_screen.dart';
import 'schedule_details_screen.dart';

/// Color scheme for course cards (rotates through these colors)
const List<Color> _courseCardColors = [
  Color(0xFF10B981), // Green
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF3B82F6), // Blue
  Color(0xFF8B5CF6), // Purple
];

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchCourses() {
    if (!mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    context.read<CourseCubit>().fetchCourses(lang: lang);
  }

  String _normalizeQuery(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // Arabic diacritics
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesCourse(CourseModel course, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;
    final langCode = Localizations.localeOf(context).languageCode;
    final normalizedName = _normalizeQuery(course.localizedName(langCode));
    final normalizedId = course.courseID.toString();
    return normalizedName.contains(normalizedQuery) ||
        normalizedId.contains(normalizedQuery);
  }

  List<LevelModel> _filterLevels(List<LevelModel> levels, String query) {
    final normalizedQuery = _normalizeQuery(query);
    if (normalizedQuery.isEmpty) return levels;

    return levels
        .map((level) {
          final filteredSemesters = level.semesters
              .map((semester) {
                final filteredCourses = semester.courses
                    .where((course) => _matchesCourse(course, normalizedQuery))
                    .toList();
                return SemesterModel(
                  semester: semester.semester,
                  courses: filteredCourses,
                );
              })
              .where((semester) => semester.courses.isNotEmpty)
              .toList();

          return LevelModel(level: level.level, semesters: filteredSemesters);
        })
        .where((level) => level.semesters.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        _fetchCourses();
      },
      child: BlocListener<CourseRegistrationCubit, CourseRegistrationState>(
        listener: (context, state) {
          if (state is CourseRegistrationUpdated && state.lastError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.lastError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.yourCourses),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchCourses,
              ),
            ],
          ),
          body: BlocBuilder<CourseCubit, CourseState>(
            builder: (context, state) {
              if (state is CourseLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CourseError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCourses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state is CourseLoaded) {
                final filteredLevels = _filterLevels(
                  state.levels,
                  _searchQuery,
                );
                if (state.levels.isEmpty) {
                  return Center(
                    child: Text(l10n.noLectures),
                  ); // Fallback if no specific "no courses" key
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth < 360
                        ? 12.0
                        : 16.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: l10n.search,
                                  hintStyle: AppTypography.bodyM.copyWith(
                                    color: isDark
                                        ? Colors.grey[500]
                                        : AppColors.textGrey600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : AppColors.textGrey600,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.inputFillDark
                                      : AppColors.cardLight.withValues(
                                          alpha: 0.5,
                                        ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: AppTypography.bodyM,
                              ),
                              const SizedBox(height: 18),
                              if (filteredLevels.isEmpty)
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? 'لا توجد نتائج مطابقة'
                                          : 'No matching courses found',
                                      style: theme.textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredLevels.length,
                                    itemBuilder: (context, index) {
                                      final level = filteredLevels[index];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${l10n.level} ${level.level}",
                                            style: AppTypography.subheadingL
                                                .copyWith(
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors.primaryDark,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppTypography.spacingM,
                                          ),
                                          ...level.semesters.map((semester) {
                                            int courseIndex = 0;
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: AppTypography
                                                            .spacingS,
                                                      ),
                                                  child: Text(
                                                    "${l10n.semester} ${semester.semester}",
                                                    style:
                                                        AppTypography.bodyMMuted(),
                                                  ),
                                                ),
                                                ...semester.courses.map((
                                                  course,
                                                ) {
                                                  final item = _buildCourseItem(
                                                    context,
                                                    course,
                                                    l10n,
                                                    isDark,
                                                    courseIndex++,
                                                  );
                                                  return item;
                                                }),
                                              ],
                                            );
                                          }),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(
    BuildContext context,
    CourseModel course,
    AppLocalizations l10n,
    bool isDark,
    int index,
  ) {
    final langCode = Localizations.localeOf(context).languageCode;
    final borderColor = _courseCardColors[index % _courseCardColors.length];

    return BlocBuilder<CourseRegistrationCubit, CourseRegistrationState>(
      builder: (context, registrationState) {
        final isRegistered = registrationState.registeredCourseIds.contains(
          course.courseID,
        );
        final isLoading =
            registrationState.loadingCourseIds[course.courseID] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: borderColor, width: 5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12), // Stronger shadow
                blurRadius: 12, // More blur
                offset: const Offset(0, 4), // More depth
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              iconColor: isDark ? Colors.white : AppColors.primaryDark,
              collapsedIconColor: isDark
                  ? Colors.grey[400]
                  : AppColors.textGrey600,
              title: Text(
                course.localizedName(langCode),
                style: AppTypography.subheadingM.copyWith(
                  color: isDark ? Colors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.courseID,
                        style: AppTypography.captionM.copyWith(
                          color: borderColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.school,
                      size: 14,
                      color: isDark ? Colors.grey[400] : AppColors.textGrey600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${course.creditHours} ${l10n.creditHours}',
                      style: AppTypography.captionM.copyWith(
                        color: isDark
                            ? Colors.grey[400]
                            : AppColors.textGrey600,
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                if (isLoading)
                  _buildLoadingState(isDark, l10n)
                else if (isRegistered)
                  _buildRegisteredState(isDark, l10n, course)
                else
                  _buildAvailableState(context, course, isDark, l10n, langCode),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build loading state for a course
  Widget _buildLoadingState(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.amber.shade300 : Colors.amber,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'جاري المعالجة...'
                  : 'Processing...',
              style: AppTypography.bodyM.copyWith(
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build registered state with View Schedule and Drop buttons
  Widget _buildRegisteredState(
    bool isDark,
    AppLocalizations l10n,
    CourseModel course,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'مسجل'
                    : 'Registered',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScheduleDetailsScreen(courseModel: course),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'الجدول'
                        : 'Schedule',
                    style: AppTypography.captionM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => _showDropConfirmation(context, course, l10n),
                  icon: const Icon(Icons.close, size: 14),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'حذف'
                        : 'Drop',
                    style: AppTypography.captionM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Show drop confirmation dialog
  void _showDropConfirmation(
    BuildContext context,
    CourseModel course,
    AppLocalizations l10n,
  ) {
    final langCode = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            langCode == 'ar' ? 'تأكيد الحذف' : 'Confirm Drop',
            style: AppTypography.subheadingM,
          ),
          content: Text(
            langCode == 'ar'
                ? 'هل أنت متأكد من رغبتك في حذف هذا المقرر؟'
                : 'Are you sure you want to drop this course?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(langCode == 'ar' ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<CourseRegistrationCubit>().dropCourse(
                  courseID: course.courseID,
                  lang: langCode,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                langCode == 'ar' ? 'حذف' : 'Drop',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build available state with register button
  Widget _buildAvailableState(
    BuildContext context,
    CourseModel course,
    bool isDark,
    AppLocalizations l10n,
    String langCode,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          context.read<CourseRegistrationCubit>().registerCourse(
            courseID: course.courseID,
            lang: langCode,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'تسجيل'
              : 'Register',
          style: AppTypography.buttonL.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
