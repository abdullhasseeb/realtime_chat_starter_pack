import 'package:flutter/material.dart';

class UPTextButtonTheme {
  UPTextButtonTheme._();

  static TextButtonThemeData light(ColorScheme scheme, TextTheme textTheme) {
    return TextButtonThemeData(style: _baseStyle(scheme, textTheme));
  }

  static TextButtonThemeData dark(ColorScheme scheme, TextTheme textTheme) {
    return TextButtonThemeData(style: _baseStyle(scheme, textTheme));
  }

  static ButtonStyle _baseStyle(ColorScheme scheme, TextTheme textTheme) {
    final labelStyle = (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    return ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      textStyle: WidgetStatePropertyAll(labelStyle),
      foregroundColor: WidgetStatePropertyAll(scheme.primary),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return scheme.primary.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return scheme.primary.withValues(alpha: 0.06);
        }
        return null;
      }),
    );
  }
}
