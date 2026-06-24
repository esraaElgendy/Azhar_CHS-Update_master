import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/course_registration_cubit.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../courses/presentation/pages/courses_screen.dart';
import '../../../grades/presentation/pages/grades_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../schedule/presentation/pages/schedule_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Logic: Fetch dashboard data immediately from backend on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final lang = Localizations.localeOf(context).languageCode;
    context.read<StudentCubit>().loadDashboard(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<CourseRegistrationCubit, CourseRegistrationState>(
          listener: (context, state) {
            if (state is CourseRegistrationUpdated && state.lastError == null && state.lastCourseId != null) {
              // Refresh dashboard data when registration state changes successfully
              _fetchData();
            }
          },
        ),
        BlocListener<StudentCubit, StudentState>(
          listener: (context, state) {
            if (state is StudentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<StudentCubit, StudentState>(
        builder: (context, state) {
        // Implementation: Map Cubit state to UI variables
        String studentName = l10n.students;
        String studentId = '';
        double gpa = 0.0;
        int completedHours = 0;
        int remainingHours = 0;
        int totalHours = 0;
        double progressValue = 0.0;
        String? profilePictureUrl;

        if (state is StudentLoaded) {
          studentName = state.user.fullName ?? state.user.name;
          studentId = state.user.studentId ?? '';
          gpa = state.user.gpa ?? 0.0;
          completedHours = state.user.completedCreditHours ?? 0;
          remainingHours = state.user.remainingCreditHours ?? 0;
          totalHours = state.user.totalCreditHours ?? (completedHours + remainingHours);
          progressValue = state.user.overallProgress ?? 0.0;
          profilePictureUrl = state.user.profilePictureUrl;
        } else if (state is StudentLoading && state.previousUser != null) {
          final user = state.previousUser!;
          studentName = user.fullName ?? user.name;
          studentId = user.studentId ?? '';
          gpa = user.gpa ?? 0.0;
          completedHours = user.completedCreditHours ?? 0;
          remainingHours = user.remainingCreditHours ?? 0;
          totalHours = user.totalCreditHours ?? (completedHours + remainingHours);
          progressValue = user.overallProgress ?? 0.0;
          profilePictureUrl = user.profilePictureUrl;
        } else if (state is StudentError && state.previousUser != null) {
          final user = state.previousUser!;
          studentName = user.fullName ?? user.name;
          studentId = user.studentId ?? '';
          gpa = user.gpa ?? 0.0;
          completedHours = user.completedCreditHours ?? 0;
          remainingHours = user.remainingCreditHours ?? 0;
          totalHours = user.totalCreditHours ?? (completedHours + remainingHours);
          progressValue = user.overallProgress ?? 0.0;
          profilePictureUrl = user.profilePictureUrl;
        }

        final progress = totalHours > 0 
            ? (progressValue > 0 ? progressValue / 100.0 : (completedHours / totalHours))
            : 0.0;

        final initials = studentName.isNotEmpty && studentName != l10n.students
            ? studentName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
            : 'ST';

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              l10n.dashboard,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                tooltip: "Reload data",
                icon: Icon(Icons.refresh, color: theme.primaryColor),
                onPressed: _fetchData,
              ),
              IconButton(
                icon: Icon(Icons.notifications_none, color: theme.primaryColor),
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => _fetchData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section: Name & ID Logic with Avatar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                            child: ProfileAvatar(
                              imageUrl: profilePictureUrl,
                              initials: initials,
                              radius: 30,
                              showEditButton: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : theme.primaryColor,
                                  ),
                                ),
                                if (studentId.isNotEmpty)
                                  Text(
                                    "${l10n.studentId}: $studentId",
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats Grid Logic: Displaying Grade and Hours
                      _buildStatCard(
                        context: context,
                        title: l10n.gba, // GBA label from localization
                        value: gpa.toStringAsFixed(2),
                        icon: Icons.analytics,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context: context,
                        title: l10n.completedCreditHours,
                        value: completedHours.toString(),
                        icon: Icons.check_circle_outline,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context: context,
                        title: l10n.remainingCreditHours,
                        value: remainingHours.toString(),
                        icon: Icons.hourglass_empty,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Overall Progress Logic
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.overallProgress,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${(progress * 100).toStringAsFixed(1)}% ${l10n.overallProgress}",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                Text(
                                  "$completedHours / $totalHours",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Navigation Menu Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMenuCard(
                            context,
                            l10n.courseRegistration,
                            Icons.app_registration,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen())),
                          ),
                          _buildMenuCard(
                            context,
                            l10n.mySchedule,
                            Icons.calendar_month,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen())),
                          ),
                          _buildMenuCard(
                            context,
                            l10n.myGrades,
                            Icons.grade,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesScreen())),
                          ),
                          _buildMenuCard(
                            context,
                            l10n.profile,
                            Icons.person_outline,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
              
              // Loading State Overlay
              if (state is StudentLoading && studentName == l10n.students)
                Container(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: theme.primaryColor, width: 6),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: AppColors.dividerDark, width: 0.5) : null,
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primaryColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
