import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/course_registration_cubit.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? course;
  final CourseModel? courseModel;

  const CourseDetailsScreen({super.key, this.course, this.courseModel})
    : assert(
        course != null || courseModel != null,
        'Either course or courseModel must be provided',
      );

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  // Mock state for interactivity

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    // Use CourseModel if provided, otherwise use mock data
    if (widget.courseModel != null) {
      return _buildCourseModelUI(
        context,
        widget.courseModel!,
        l10n,
        theme,
        isDark,
        langCode,
      );
    } else {
      return _buildMockCourseUI(
        context,
        widget.course ?? AppConstants.courseDetailsMath2,
        l10n,
        theme,
        isDark,
        langCode,
      );
    }
  }

  Widget _buildCourseModelUI(
    BuildContext context,
    CourseModel courseModel,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    String langCode,
  ) {
    return BlocListener<CourseRegistrationCubit, CourseRegistrationState>(
      listener: (context, state) {
        if (state is CourseRegistrationUpdated &&
            state.lastError != null &&
            state.lastCourseId == courseModel.courseID) {
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: isDark ? Colors.white : Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        courseModel.localizedName(langCode),
                        style: AppTypography.headingM.copyWith(
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTypography.spacingM,
                        vertical: AppTypography.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppTypography.radiusM,
                        ),
                      ),
                      child: Text(
                        courseModel.courseID,
                        style: AppTypography.badgeL.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildInfoRow(
                  Icons.hourglass_bottom,
                  l10n.creditHoursLabel(courseModel.creditHours),
                  isDark,
                ),
                const SizedBox(height: 40),
                const SizedBox(height: 40),
                BlocBuilder<CourseRegistrationCubit, CourseRegistrationState>(
                  builder: (context, state) {
                    final cubit = context.read<CourseRegistrationCubit>();
                    final isRegistered = cubit.isRegistered(courseModel.courseID);
                    final isLoading = cubit.isLoading(courseModel.courseID);

                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered
                              ? (isDark
                                    ? AppColors.inputFillDark
                                    : const Color(0xffDBDEFF))
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isRegistered) {
                                  cubit.dropCourse(
                                    courseID: courseModel.courseID,
                                    lang: langCode,
                                  );
                                } else {
                                  cubit.registerCourse(
                                    courseID: courseModel.courseID,
                                    lang: langCode,
                                  );
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isRegistered ? l10n.drop : l10n.register,
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isRegistered
                                      ? (isDark ? Colors.white : AppColors.primary)
                                      : Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockCourseUI(
    BuildContext context,
    Map<String, dynamic> course,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    String langCode,
  ) {
    final localizedName = _localizedCourseField(
      course,
      langCode,
      fallbackKey: 'name',
      enKeys: const [
        'nameEn',
        'nameEN',
        'englishName',
        'courseNameEn',
        'courseNameEN',
        'name_en',
      ],
      arKeys: const [
        'nameAr',
        'nameAR',
        'arabicName',
        'courseNameAr',
        'courseNameAR',
        'name_ar',
      ],
    );

    final isFull = (course['enrolled'] ?? 0) >= (course['capacity'] ?? 0);
    final hasConflict = course['hasConflict'] ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: BlocBuilder<CourseRegistrationCubit, CourseRegistrationState>(
            builder: (context, state) {
              final cubit = context.read<CourseRegistrationCubit>();
              final courseId = (course['code'] ?? course['id'] ?? "CODE").toString();
              final isRegistered = cubit.isRegistered(courseId);
              final isLoading = cubit.isLoading(courseId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      localizedName.isNotEmpty
                          ? localizedName
                          : course['name'] ?? "Course Name",
                      style: AppTypography.headingM.copyWith(
                        color: AppColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTypography.spacingM,
                      vertical: AppTypography.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppTypography.radiusM,
                      ),
                    ),
                    child: Text(
                      course['code'] ?? "CODE",
                      style: AppTypography.badgeL.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(course['instructors'] ?? "", style: AppTypography.bodyM),
              const SizedBox(height: 30),
              _buildInfoRow(
                Icons.access_time,
                l10n.creditHoursLabel(course['creditHours'] ?? 3),
                isDark,
              ),
              const SizedBox(height: 16),
              Text(
                course['time'] ?? "",
                style: GoogleFonts.cairo(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    l10n.prerequisites + " : ",
                    style: GoogleFonts.cairo(fontSize: 16),
                  ),
                  Text(
                    course['prerequisite'] ?? "",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 28,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${course['enrolled']}/${course['capacity']}",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (isFull && !isRegistered) _buildWarning(l10n.courseFull),
              if (hasConflict && !isRegistered)
                _buildWarning(l10n.courseConflict),
              if (isRegistered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.registered,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered
                        ? (isDark
                              ? AppColors.inputFillDark
                              : const Color(0xffDBDEFF))
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isRegistered) {
                            cubit.dropCourse(courseID: courseId, lang: langCode);
                          } else {
                            cubit.registerCourse(courseID: courseId, lang: langCode);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isRegistered ? l10n.drop : l10n.register,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isRegistered
                                ? (isDark ? Colors.white : AppColors.primary)
                                : Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    ),
  ),
);
}

  String _localizedCourseField(
    Map<String, dynamic> course,
    String languageCode, {
    required String fallbackKey,
    required List<String> enKeys,
    required List<String> arKeys,
  }) {
    String? value(String key) => course[key]?.toString().trim();

    final values = <dynamic>[];
    if (languageCode == 'ar') {
      values.addAll(arKeys.map(value));
      values.addAll(enKeys.map(value));
    } else {
      values.addAll(enKeys.map(value));
      values.addAll(arKeys.map(value));
    }
    values.add(value(fallbackKey));

    return _firstNonEmptyString(values) ?? '';
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.cairo(fontSize: 16)),
      ],
    );
  }

  Widget _buildWarning(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
