import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class UPTextTheme {
  UPTextTheme._();

  static TextTheme lightTextTheme = const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: UPColors.primary),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: UPColors.primary),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: UPColors.primary),

    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UPColors.primary),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: UPColors.primary),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: UPColors.primary),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: UPColors.primary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: UPColors.primary),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: UPColors.primary),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: UPColors.primary),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: UPColors.primary),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: UPColors.primary),
  );

  static TextTheme darkTextTheme = const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: UPColors.textWhite),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: UPColors.textWhite),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: UPColors.textWhite),

    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: UPColors.textWhite),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: UPColors.textWhite),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: UPColors.textWhite),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: UPColors.textWhite),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: UPColors.textWhite),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: UPColors.textWhite),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: UPColors.textWhite),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: UPColors.textWhite),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: UPColors.textWhite),
  );
}
