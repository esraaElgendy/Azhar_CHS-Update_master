import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class MediaPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Shows a beautiful bottom sheet to pick an image from camera or gallery.
  static Future<void> showImageSourceSheet({
    required BuildContext context,
    required Function(File) onImageSelected,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectImage,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    label: l10n.gallery,
                    onTap: () => _pickImage(
                      context: context,
                      source: ImageSource.gallery,
                      onImageSelected: onImageSelected,
                    ),
                  ),
                  _buildPickerOption(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    label: l10n.camera,
                    onTap: () => _pickImage(
                      context: context,
                      source: ImageSource.camera,
                      onImageSelected: onImageSelected,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _pickImage({
    required BuildContext context,
    required ImageSource source,
    required Function(File) onImageSelected,
  }) async {
    try {
      Navigator.pop(context);
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (picked != null) {
        onImageSelected(File(picked.path));
      }
    } on PlatformException catch (e) {
      _showError(context, _getErrorMessage(e));
    } catch (e) {
      _showError(context, "Failed to pick image: ${e.toString()}");
    }
  }

  static String _getErrorMessage(PlatformException e) {
    switch (e.code) {
      case 'camera_access_denied':
        return 'Camera access denied. Please enable it in settings.';
      case 'photo_access_denied':
        return 'Photo library access denied. Please enable it in settings.';
      case 'multiple_request':
        return 'A request is already in progress.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
