import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../courses/presentation/pages/courses_screen.dart';
import '../../../grades/presentation/pages/grades_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../schedule/presentation/pages/schedule_screen.dart';
import '../../../fees/presentation/pages/fees_screen.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const CoursesScreen(),
    const ScheduleScreen(),
    const GradesScreen(),
    const FeesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Responsive nav label font size — shrinks slightly in Arabic to fit 5 items
    final double labelFontSize = isAr ? 10.0 : 11.0;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.home,
                  isDark: isDark,
                  labelFontSize: labelFontSize,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.book_outlined,
                  activeIcon: Icons.book,
                  label: l10n.courses,
                  isDark: isDark,
                  labelFontSize: labelFontSize,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: l10n.schedule,
                  isDark: isDark,
                  labelFontSize: labelFontSize,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.grade_outlined,
                  activeIcon: Icons.grade,
                  label: l10n.grades,
                  isDark: isDark,
                  labelFontSize: labelFontSize,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: l10n.fees,
                  isDark: isDark,
                  labelFontSize: labelFontSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
    required double labelFontSize,
  }) {
    final isSelected = _currentIndex == index;
    final Color selectedColor = AppColors.primary;
    final Color unselectedColor =
        isDark ? Colors.white38 : AppColors.textGrey600;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated indicator dot
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? selectedColor : unselectedColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.cairo(
                  fontSize: labelFontSize,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                  height: 1.2,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Active indicator dot
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isSelected ? 18 : 0,
                height: isSelected ? 3 : 0,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
