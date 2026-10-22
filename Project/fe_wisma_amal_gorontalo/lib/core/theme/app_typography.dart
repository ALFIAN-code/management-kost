import 'package:flutter/material.dart';
import 'package:frontend/core/theme/color_schemes.dart';

class AppTypography {
  const AppTypography._();

  // ==================== DISPLAY ====================
  // For main page titles like "Dashboard"
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle displayLargeDark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle displayMediumDark = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // ==================== HEADLINE ====================
  // For section headers like "Maintenance Schedule", "Damage Report"
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle headlineLargeDark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle headlineMediumDark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle headlineSmallDark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // ==================== TITLE ====================
  // For card titles, dialog titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle titleLargeDark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle titleMediumDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle titleSmallDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // ==================== BODY ====================
  // For main content, paragraphs, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMediumDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle bodySmallDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // ==================== LABEL ====================
  // For buttons, chips, tabs, table headers
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle labelLargeDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle labelMediumDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle labelSmallLight = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle labelSmallDark = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondaryDark,
    fontFamily: 'Inter',
  );

  // ==================== SPECIALIZED ====================
  // For specific mockup needs

  // For large numbers in stats cards (10, 3, etc.)
  static const TextStyle statsNumber = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -1,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle statsNumberDark = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -1,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // For labels in stats cards ("Damage Report", etc.)
  static const TextStyle statsLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle statsLabelDark = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondaryDark,
    fontFamily: 'Inter',
  );

  // For table headers
  static const TextStyle tableHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle tableHeaderDark = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondaryDark,
    fontFamily: 'Inter',
  );

  // For table cells
  static const TextStyle tableCell = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle tableCellDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // For sidebar menu
  static const TextStyle menuItem = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle menuItemDark = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  static const TextStyle menuItemActive = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle menuItemActiveDark = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // For caption/timestamp like "20-05-2025 05.50 WIB"
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textSecondaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle captionDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textSecondaryDark,
    fontFamily: 'Inter',
  );

  // For user name in card like "susi susanti"
  static const TextStyle userName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle userNameDark = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimaryDark,
    fontFamily: 'Inter',
  );

  // For info details like "room 201"
  static const TextStyle infoDetail = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondaryLight,
    fontFamily: 'Inter',
  );

  static const TextStyle infoDetailDark = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondaryDark,
    fontFamily: 'Inter',
  );
}
