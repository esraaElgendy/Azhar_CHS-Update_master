import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/student_cubit.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/utils/media_picker_helper.dart';
import '../../../../l10n/app_localizations.dart';
import 'dart:io';
import '../../../../core/utils/profile_image_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _majorController;
  late TextEditingController _phoneController;
  late String _studentID;
  String? selectedYear;
  String? selectedSemester;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _majorController = TextEditingController();
    _phoneController = TextEditingController();
    _studentID = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final cubit = context.read<StudentCubit>();
      final state = cubit.state;
      UserModel? user;
      
      if (state is StudentLoaded) {
        user = state.user;
      } else if (state is StudentLoading) {
        user = state.previousUser;
      } else if (state is StudentError) {
        user = state.previousUser;
      }

      if (user != null) {
        _nameController.text = user.name;
        _fullNameController.text = user.fullName ?? user.name;
        _emailController.text = user.email;
        _majorController.text = user.major ?? '';
        _phoneController.text = user.phone ?? '';
        _studentID = user.studentId ?? user.id;
        selectedYear = user.year;
        selectedSemester = user.semester;
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<StudentCubit, StudentState>(
      listener: (context, state) {
        if (state is StudentLoaded && _isSaving) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.save), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
          );
          Navigator.pop(context);
        } else if (state is StudentError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is StudentLoading;
        UserModel? user;
        if (state is StudentLoaded) user = state.user;
        else if (state is StudentLoading) user = state.previousUser;
        else if (state is StudentImageUploading) user = state.previousUser;
        else if (state is StudentError) user = state.previousUser;

        final initials = (user?.fullName ?? user?.name ?? 'ST').split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor), onPressed: () => Navigator.pop(context)),
            title: Text(l10n.editProfile, style: GoogleFonts.cairo(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        children: [
                          ProfileAvatar(imageUrl: user?.profilePictureUrl, initials: initials, radius: 55, isLoading: state is StudentImageUploading),
                          Positioned(
                            right: 0, bottom: 0,
                            child: GestureDetector(
                              onTap: () => _showImageSourceActionSheet(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle, border: Border.all(color: theme.scaffoldBackgroundColor, width: 3)),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildInputField(label: l10n.name, controller: _nameController, icon: Icons.person_outline_rounded, isDark: isDark, theme: theme),
                    const SizedBox(height: 20),
                    _buildInputField(label: l10n.fullName, controller: _fullNameController, icon: Icons.badge_outlined, isDark: isDark, theme: theme),
                    const SizedBox(height: 20),
                    _buildInputField(label: l10n.email, controller: _emailController, icon: Icons.email_outlined, isDark: isDark, theme: theme, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildInputField(label: l10n.major, controller: _majorController, icon: Icons.school_outlined, isDark: isDark, theme: theme),
                    const SizedBox(height: 20),
                    _buildDropdown(label: l10n.yourYear, value: selectedYear, items: ["First Year", "Second Year", "Third Year", "Fourth Year"], isDark: isDark, theme: theme, onChanged: (v) => setState(() => selectedYear = v)),
                    const SizedBox(height: 20),
                    _buildDropdown(label: l10n.semester, value: selectedSemester, items: ["Semester 1", "Semester 2", "Semester 3"], isDark: isDark, theme: theme, onChanged: (v) => setState(() => selectedSemester = v)),
                    const SizedBox(height: 20),
                    _buildInputField(label: l10n.phone, controller: _phoneController, icon: Icons.phone_android_rounded, isDark: isDark, theme: theme, keyboardType: TextInputType.phone),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 2),
                        onPressed: isLoading ? null : _saveProfile,
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(l10n.save, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (isLoading) Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required IconData icon, required bool isDark, required ThemeData theme, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4), child: Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87))),
        Container(
          decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
          child: TextField(controller: controller, keyboardType: keyboardType, style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600), decoration: InputDecoration(prefixIcon: Icon(icon, color: theme.primaryColor, size: 22), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16))),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required bool isDark, required ThemeData theme, required ValueChanged<String?> onChanged}) {
    final list = [...items];
    if (value != null && !list.contains(value)) list.add(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4), child: Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, isExpanded: true, icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor), dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              items: list.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.cairo(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    final lang = Localizations.localeOf(context).languageCode;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name cannot be empty"), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _isSaving = true);
    context.read<StudentCubit>().updateProfile(
      studentID: _studentID, name: _nameController.text.trim(), fullName: _fullNameController.text.trim(), email: _emailController.text.trim(),
      major: _majorController.text.trim(), year: selectedYear ?? '', semester: selectedSemester ?? '', phone: _phoneController.text.trim(), lang: lang,
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    MediaPickerHelper.showImageSourceSheet(context: context, onImageSelected: (file) => _handlePickedImage(file));
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
}
