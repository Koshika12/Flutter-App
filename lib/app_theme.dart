import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B1F3B);
  static const Color primaryDark = Color(0xFF173A8A);
  static const Color primaryTint = Color(0xFFF5F7FB);
  static const Color scaffoldBackground = Color(0xFFF5F7FB);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B1F3B), Color(0xFF2142B2)],
  );
}
