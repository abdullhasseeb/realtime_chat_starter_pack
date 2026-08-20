import 'package:flutter/material.dart';

class UPFilledButtonTheme {
  UPFilledButtonTheme._();

  static FilledButtonThemeData light(ColorScheme scheme, TextTheme textTheme) {
    return FilledButtonThemeData(style: _baseStyle(scheme, textTheme));
  }

  static FilledButtonThemeData dark(ColorScheme scheme, TextTheme textTheme) {
    return FilledButtonThemeData(style: _baseStyle(scheme, textTheme));
  }

  static ButtonStyle _baseStyle(ColorScheme scheme, TextTheme textTheme) {
    final labelStyle = (textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      textStyle: WidgetStatePropertyAll(labelStyle),

      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.surfaceContainerHighest;
        }
        return scheme.primary;
      }),

      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurfaceVariant;
        }
        return scheme.onPrimary;
      }),

      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0;
        if (states.contains(WidgetState.pressed)) return 0;
        return 1;
      }),

      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return scheme.onPrimary.withValues(alpha: 0.10);
        }
        if (states.contains(WidgetState.hovered)) {
          return scheme.onPrimary.withValues(alpha: 0.06);
        }
        return null;
      }),
    );
  }
}
