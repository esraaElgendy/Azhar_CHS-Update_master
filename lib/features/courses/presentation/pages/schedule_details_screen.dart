import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/course_registration_cubit.dart';
import '../../../../core/bloc/schedule_cubit.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/models/schedule_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class ScheduleDetailsScreen extends StatefulWidget {
  final CourseModel courseModel;

  const ScheduleDetailsScreen({super.key, required this.courseModel});

  @override
  State<ScheduleDetailsScreen> createState() => _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends State<ScheduleDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  void _loadSchedule() {
    final lang = Localizations.localeOf(context).languageCode;
    context.read<ScheduleCubit>().loadSchedule(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    return BlocListener<CourseRegistrationCubit, CourseRegistrationState>(
      listener: (context, state) {
        if (state is CourseRegistrationUpdated &&
            state.lastCourseId == widget.courseModel.courseID) {
          if (state.lastError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.lastError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // Success
            final isRegistered = context
                .read<CourseRegistrationCubit>()
                .isRegistered(widget.courseModel.courseID);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isRegistered ? l10n.registered : l10n.drop),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: isDark ? Colors.white : Colors.black),
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, scheduleState) {
            final List<ScheduleModel> filteredSchedule =
                scheduleState is ScheduleLoaded
                ? scheduleState.filterByCourseId(widget.courseModel.courseID)
                : [];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.courseModel.localizedName(langCode),
                          style: GoogleFonts.cairo(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xff3D4AB7),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff3D4AB7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.courseModel.courseID,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Instructors
                  if (filteredSchedule.isNotEmpty) ...[
                    Text(
                      filteredSchedule
                          .map((s) => s.instructorName)
                          .toSet()
                          .join('\n'),
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        color: isDark ? Colors.grey[300] : Colors.black,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Hours
                  _buildIconTextRow(
                    Icons.access_time,
                    "${l10n.creditHours} : ${widget.courseModel.creditHours}",
                    isDark,
                  ),
                  const SizedBox(height: 16),

                  // Time - Taking first session as sample for the header
                  if (filteredSchedule.isNotEmpty) ...[
                    Text(
                      "${filteredSchedule.first.day} ${filteredSchedule.first.startTime} - ${filteredSchedule.first.endTime}",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        color: isDark ? Colors.grey[300] : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Prerequisites
                  Row(
                    children: [
                      Text(
                        "${l10n.prerequisites} : ",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          color: isDark ? Colors.grey[300] : Colors.black,
                        ),
                      ),
                      Text(
                        "ENG101", // Placeholder or dynamic if model updated
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Enrollment
                  _buildIconTextRow(
                    Icons.person_outline,
                    "25/15", // Placeholder
                    isDark,
                    iconSize: 32,
                    fontSize: 24,
                  ),
                  const SizedBox(height: 60),

                  // Registration Status Indicator
                  BlocBuilder<CourseRegistrationCubit, CourseRegistrationState>(
                    builder: (context, regState) {
                      final isRegistered = context
                          .read<CourseRegistrationCubit>()
                          .isRegistered(widget.courseModel.courseID);
                      if (isRegistered) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.registered,
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Action Button
                  BlocBuilder<CourseRegistrationCubit, CourseRegistrationState>(
                    builder: (context, regState) {
                      final cubit = context.read<CourseRegistrationCubit>();
                      final isRegistered = cubit.isRegistered(
                        widget.courseModel.courseID,
                      );
                      final isLoading = cubit.isLoading(
                        widget.courseModel.courseID,
                      );

                      return SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered
                                ? const Color(0xffE0E4FF)
                                : const Color(0xff3D4AB7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isRegistered) {
                                    cubit.dropCourse(
                                      courseID: widget.courseModel.courseID,
                                      lang: langCode,
                                    );
                                  } else {
                                    cubit.registerCourse(
                                      courseID: widget.courseModel.courseID,
                                      lang: langCode,
                                    );
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isRegistered ? l10n.drop : l10n.register,
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isRegistered
                                        ? const Color(0xff3D4AB7)
                                        : Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Detailed Schedule Section
                  Text(
                    l10n.schedule,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xff3D4AB7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (scheduleState is ScheduleLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (scheduleState is ScheduleError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          scheduleState.message,
                          style: GoogleFonts.cairo(color: AppColors.error),
                        ),
                      ),
                    )
                  else if (scheduleState is ScheduleLoaded &&
                      filteredSchedule.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          l10n.noLectures ?? "No schedule available",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredSchedule.map(
                      (schedule) => _buildScheduleCard(schedule, isDark),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule, bool isDark) {
    final isLecture = schedule.sessionType.toUpperCase() == 'LECTURE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E1E2C) : const Color(0xffEBEBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isLecture
                      ? const Color(0xff6C72FF)
                      : const Color(0xff4D5596),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  schedule.sessionType,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                schedule.day,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(
            Icons.person_outline,
            schedule.instructorName,
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            "${schedule.startTime} - ${schedule.endTime}",
            isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.room_outlined, schedule.room, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xff3D4AB7).withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextRow(
    IconData icon,
    String text,
    bool isDark, {
    double iconSize = 28,
    double fontSize = 20,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: isDark ? Colors.grey[400] : Colors.black54,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: fontSize,
            color: isDark ? Colors.grey[300] : Colors.black,
          ),
        ),
      ],
    );
  }
}
