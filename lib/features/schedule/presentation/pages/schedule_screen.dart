import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/schedule_cubit.dart';
import '../../../../core/models/schedule_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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

  Map<String, List<ScheduleModel>> _groupScheduleByDay(
    List<ScheduleModel> schedule,
  ) {
    final Map<String, List<ScheduleModel>> grouped = {};
    for (var session in schedule) {
      final day = session.day.isNotEmpty ? session.day : 'Unknown';
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(session);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.mySchedule,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: theme.primaryColor,
            ),
            onPressed: _loadSchedule, // Added refresh functionality
          ),
        ],
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScheduleError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSchedule,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ScheduleLoaded) {
            if (state.schedule.isEmpty) {
              return Center(child: _buildEmptyState(context, isDark, true));
            }

            final groupedSchedule = _groupScheduleByDay(state.schedule);
            final days = groupedSchedule.keys.toList();

            return RefreshIndicator(
              onRefresh: () async {
                _loadSchedule();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final String day = days[index];
                  final List<ScheduleModel> lectures = groupedSchedule[day]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTypography.spacingM,
                        ),
                        child: Text(
                          day,
                          style: AppTypography.subheadingL.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: lectures.isEmpty ? 180 : 240,
                        child: lectures.isEmpty
                            ? _buildEmptyState(context, isDark, false)
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 4),
                                itemCount: lectures.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, lectureIndex) {
                                  final lecture = lectures[lectureIndex];
                                  return Container(
                                    width: 280,
                                    alignment: Alignment.center,
                                    child: _buildLectureCard(
                                      context,
                                      lecture,
                                      isDark,
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLectureCard(
    BuildContext context,
    ScheduleModel lecture,
    bool isDark,
  ) {
    final type = lecture.sessionType.toUpperCase();
    final isLecture = type == 'LECTURE';
    final isLab = type == 'LAB' || type == 'LAP';
    final theme = Theme.of(context);

    Color badgeColor = const Color(0xff4D5596); // Default
    if (isLecture) badgeColor = theme.primaryColor;
    if (isLab) badgeColor = const Color(0xff8B5CF6); // Distinct Purple for Labs

    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark
            : const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lecture.courseName.isNotEmpty
                      ? lecture.courseName
                      : lecture.courseID,
                  style: AppTypography.subheadingM.copyWith(
                    color: theme.primaryColor,
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
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(AppTypography.radiusXL),
                ),
                child: Text(
                  lecture.sessionType,
                  style: AppTypography.badgeM.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                Icons.access_time_filled,
                "${lecture.startTime} - ${lecture.endTime}",
                isDark,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.person, lecture.instructorName, isDark),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.location_on, lecture.room, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: AppTypography.spacingXS),
        Expanded(
          child: Text(
            text.isNotEmpty ? text : '-',
            style: AppTypography.bodyS.copyWith(
              color: isDark ? Colors.grey[300] : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, bool fullPage) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: fullPage ? 80 : 40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: fullPage ? 64 : 40,
            color: const Color(0xff9DA2FF),
          ),
          SizedBox(height: fullPage ? 16 : 10),
          Text(
            l10n.noLectures, // Reverting to original valid l10n property
            style: AppTypography.bodyM.copyWith(color: const Color(0xff9DA2FF)),
          ),
        ],
      ),
    );
  }
}
