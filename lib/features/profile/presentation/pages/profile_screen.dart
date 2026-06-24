import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/bloc/auth_cubit.dart';
import '../../../../core/bloc/settings_cubit.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/utils/media_picker_helper.dart';
import '../../../../core/utils/profile_image_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'academic_advisor_chat_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
    });
  }

  void _fetchProfile() {
    if (!mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    context.read<StudentCubit>().loadProfile(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.profile,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: theme.primaryColor),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<StudentCubit, StudentState>(
        listener: (context, state) {
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          UserModel? user;
          bool isUploading = state is StudentImageUploading;

          if (state is StudentLoaded) user = state.user;
          else if (state is StudentLoading) user = state.previousUser;
          else if (state is StudentImageUploading) user = state.previousUser;
          else if (state is StudentError) user = state.previousUser;

          if (state is StudentLoading && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayName = user?.fullName ?? user?.name ?? l10n.students;
          final initials = displayName.isNotEmpty && displayName != l10n.students
              ? displayName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
              : 'ST';

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _fetchProfile(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Circular Avatar with Camera Icon on Side
                        Center(
                          child: Stack(
                            children: [
                              ProfileAvatar(
                                imageUrl: user?.profilePictureUrl,
                                initials: initials,
                                radius: 60,
                                isLoading: isUploading,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _showImageSourceActionSheet(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          displayName,
                          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.studentId ?? user?.id ?? '',
                          style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 30),
                        
                        // Academic Stats Row (3 Small Containers)
                        Row(
                          children: [
                            _buildStatCard(l10n.gba, (user?.gpa ?? 0.0).toStringAsFixed(2), Icons.auto_awesome_rounded, Colors.amber, isDark),
                            const SizedBox(width: 12),
                            _buildStatCard(l10n.completedCreditHours, (user?.completedCreditHours ?? 0).toString(), Icons.check_circle_rounded, Colors.green, isDark),
                            const SizedBox(width: 12),
                            _buildStatCard(l10n.semester, _localizeValue(user?.semester, lang), Icons.calendar_view_day_rounded, Colors.blue, isDark),
                          ],
                        ),

                        const SizedBox(height: 30),
                        const Divider(),
                        
                        // Personal Info List (Remaining items)
                        _buildInfoTile(l10n.fullName, user?.fullName ?? '', Icons.badge_outlined, isDark),
                        _buildInfoTile(l10n.name, user?.name ?? '', Icons.person_outline, isDark),
                        _buildInfoTile(l10n.email, user?.email ?? '', Icons.email_outlined, isDark),
                        _buildInfoTile(l10n.major, _localizeValue(user?.major, lang), Icons.school_outlined, isDark),
                        _buildInfoTile(l10n.yourYear, _localizeValue(user?.year, lang), Icons.auto_awesome_outlined, isDark),
                        _buildInfoTile(l10n.semester, _localizeValue(user?.semester, lang), Icons.calendar_today_outlined, isDark),
                        _buildInfoTile(l10n.phone, user?.phone ?? '', Icons.phone_android_rounded, isDark),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        
                        // Settings (Old Style)
                        _buildActionTile(l10n.language, lang.toUpperCase(), Icons.language_rounded, onTap: () => context.read<SettingsCubit>().toggleLocale()),
                        _buildActionTile(l10n.darkMode, null, Icons.dark_mode_outlined, 
                          trailing: BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, s) => Switch.adaptive(
                              value: s.themeMode == ThemeMode.dark, 
                              activeColor: theme.primaryColor,
                              onChanged: (v) => context.read<SettingsCubit>().toggleTheme(v)
                            ),
                          )
                        ),
                        _buildActionTile(
                          l10n.contactAcademicAdvisor,
                          null,
                          Icons.chat_bubble_outline_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AcademicAdvisorChatScreen()),
                          ),
                        ),
                        _buildActionTile(l10n.logout, null, Icons.logout_rounded, isDestructive: true, onTap: () => _showLogoutDialog(context, l10n)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed Bottom Edit Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    child: Text(
                      l10n.editProfile,
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                Text(value, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String label, String? value, IconData icon, {VoidCallback? onTap, Widget? trailing, bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 22),
      ),
      title: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      trailing: trailing ??
          (value != null
              ? Text(value, style: GoogleFonts.cairo(color: AppColors.textGrey))
              : const Icon(Icons.arrow_forward_ios_rounded, size: 14)),
    );
  }

  String _localizeValue(String? value, String lang) {
    if (value == null || value.isEmpty) return '---';
    if (lang != 'ar') return value;
    final Map<String, String> translations = {
      'First Year': 'السنة الأولى', 'Second Year': 'السنة الثانية', 'Third Year': 'السنة الثالثة', 'Fourth Year': 'السنة الرابعة',
      'level 1': 'المستوى الأول', 'level 2': 'المستوى الثاني', 'level 3': 'المستوى الثالث', 'level 4': 'المستوى الرابع',
      'First Semester': 'الفصل الدراسي الأول', 'Second Semester': 'الفصل الدراسي الثاني', 'Semester 1': 'ترم أول', 'Semester 2': 'ترم ثاني',
      'System and Computer': 'هندسة النظم والحاسبات',
    };
    return translations[value] ?? value;
  }

  void _showImageSourceActionSheet(BuildContext context) {
    MediaPickerHelper.showImageSourceSheet(
      context: context,
      onImageSelected: (file) => _handlePickedImage(file),
    );
  }

  Future<void> _handlePickedImage(File file) async {
    final cubit = context.read<StudentCubit>();
    try {
      final savedPath = await ProfileImageStorage.saveFile(file);
      await cubit.selectLocalProfileImage(savedPath);
      final lang = Localizations.localeOf(context).languageCode;
      await cubit.uploadProfileImage(file: File(savedPath), lang: lang);
    } catch (e) {
      cubit.selectLocalProfileImage(file.path);
      final lang = Localizations.localeOf(context).languageCode;
      await cubit.uploadProfileImage(file: file, lang: lang);
    }
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logout, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(onPressed: () {
            context.read<AuthCubit>().logout();
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
          }, child: Text(l10n.logout, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}



