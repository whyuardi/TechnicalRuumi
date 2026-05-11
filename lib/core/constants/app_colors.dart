// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Orange from RUUMI
  static const Color primary = Color(0xFFFF5A00);
  static const Color primaryLight = Color(0xFFFF7A30);
  static const Color primaryDark = Color(0xFFCC4800);

  // Neutral
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F8F8);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFFAAAAAA);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Step progress
  static const Color stepActive = Color(0xFFFF5A00);
  static const Color stepInactive = Color(0xFFE0E0E0);
  static const Color stepCompleted = Color(0xFFFF5A00);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFFE8E8E8);
}
