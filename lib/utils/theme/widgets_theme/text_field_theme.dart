import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class UPTextFieldTheme {
  UPTextFieldTheme._();

  static InputDecorationTheme light = InputDecorationTheme(
    isDense: true,

    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

    // Label / hint styles
    hintStyle: TextStyle(color: UPColors.textPrimary.withAlpha(140)),
    labelStyle: TextStyle(color: UPColors.textPrimary.withAlpha(180)),

    // Default border
    border: InputBorder.none,

    // Enabled
    enabledBorder: InputBorder.none,

    // Focused
    focusedBorder: InputBorder.none,

    // Error
    errorBorder: InputBorder.none,

    focusedErrorBorder: InputBorder.none,

    errorStyle: const TextStyle(height: 1.2),
  );

  static InputDecorationTheme dark = InputDecorationTheme(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    hintStyle: TextStyle(color: UPColors.textWhite.withAlpha(160)),
    labelStyle: TextStyle(color: UPColors.textWhite.withAlpha(190)),

    border: InputBorder.none,

    enabledBorder: InputBorder.none,

    focusedBorder: InputBorder.none,

    errorBorder: InputBorder.none,

    focusedErrorBorder: InputBorder.none,

    errorStyle: const TextStyle(height: 1.2),
  );
}
