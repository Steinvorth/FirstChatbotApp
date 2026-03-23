import 'package:flutter/material.dart';

/// App-wide color palette.
/// Usage: AppColors.primary, AppColors.surface, etc.
class AppColors {
  AppColors._();

  // --- Brand ---
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7FF0);
  static const Color primaryDark = Color(0xFF5540D4);

  // --- Surfaces ---
  static const Color background = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A24);
  static const Color surfaceLight = Color(0xFF24243A);
  static const Color surfaceBorder = Color(0xFF2E2E48);

  // --- Text ---
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF9999B3);
  static const Color textMuted = Color(0xFF66668A);

  // --- Chat bubbles ---
  static const Color userBubble = Color(0xFF6C5CE7);
  static const Color userBubbleText = Color(0xFFFFFFFF);
  static const Color aiBubble = Color(0xFF1E1E30);
  static const Color aiBubbleText = Color(0xFFF0F0F5);

  // --- Accents ---
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF5252);
  static const Color divider = Color(0xFF2A2A40);
}
