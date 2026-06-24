import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Comprehensive typography system with clear hierarchy
class AppTypography {
  // Heading Styles - Large, bold text for page titles
  static TextStyle get headingXL => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get headingL => GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get headingM => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static TextStyle get headingS =>
      GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, height: 1.3);

  // Subheading Styles - Semi-bold for section titles
  static TextStyle get subheadingL =>
      GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3);

  static TextStyle get subheadingM =>
      GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4);

  static TextStyle get subheadingS =>
      GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4);

  // Body Styles - Regular text content
  static TextStyle get bodyL =>
      GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5);

  static TextStyle get bodyM =>
      GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5);

  static TextStyle get bodyS =>
      GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, height: 1.5);

  // Caption Styles - Small, muted text for labels
  static TextStyle get captionL => GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static TextStyle get captionM => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static TextStyle get captionS => GoogleFonts.cairo(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
  );

  // Button Styles - For interactive elements
  static TextStyle get buttonL => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonM => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static TextStyle get buttonS => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // Badge/Label Styles - For small labels
  static TextStyle get badgeL =>
      GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, height: 1.2);

  static TextStyle get badgeM =>
      GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2);

  // Numeric/Statistic Styles - For displaying numbers
  static TextStyle get statisticXL =>
      GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1);

  static TextStyle get statisticL =>
      GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w800, height: 1.1);

  static TextStyle get statisticM =>
      GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, height: 1.2);

  // Colored Text Variants
  static TextStyle headingXLDark() =>
      headingXL.copyWith(color: AppColors.primaryDark);
  static TextStyle headingLDark() =>
      headingL.copyWith(color: AppColors.primaryDark);
  static TextStyle headingMDark() =>
      headingM.copyWith(color: AppColors.primaryDark);
  static TextStyle headingSDark() =>
      headingS.copyWith(color: AppColors.primaryDark);

  static TextStyle subheadingLPrimary() =>
      subheadingL.copyWith(color: AppColors.primary);
  static TextStyle subheadingMPrimary() =>
      subheadingM.copyWith(color: AppColors.primary);

  static TextStyle bodyLMuted() => bodyL.copyWith(color: AppColors.textGrey);
  static TextStyle bodyMMuted() => bodyM.copyWith(color: AppColors.textGrey);
  static TextStyle bodySMuted() => bodyS.copyWith(color: AppColors.textGrey);

  static TextStyle bodyLSubtle() =>
      bodyL.copyWith(color: AppColors.primary.withOpacity(0.75));
  static TextStyle bodyMSubtle() =>
      bodyM.copyWith(color: AppColors.primary.withOpacity(0.75));
  static TextStyle bodySSubtle() =>
      bodyS.copyWith(color: AppColors.primary.withOpacity(0.75));

  static TextStyle captionLMuted() =>
      captionL.copyWith(color: AppColors.primary.withOpacity(0.75));
  static TextStyle captionMMuted() =>
      captionM.copyWith(color: AppColors.primary.withOpacity(0.75));

  // Common spacing constants
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 20;
  static const double spacingXXL = 24;
  static const double spacing3XL = 28;
  static const double spacing4XL = 32;

  // Common border radius constants
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radius2XL = 24;
  static const double radius3XL = 28;
  static const double radius4XL = 32;
}
