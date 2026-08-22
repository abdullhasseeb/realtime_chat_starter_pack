import 'package:flutter/material.dart';
import 'adaptive_value.dart';
import 'units.dart';

/// App-wide layout tokens (padding, gaps, sizes)
/// - Use this instead of repeating adaptiveValue() in every screen.
/// - Keep values stable so UI stays consistent across the app.
class UPLayout {
  UPLayout._();

  // ---------------------------------------------------------------------------
  // Screen padding (the default horizontal padding you use everywhere)
  // ---------------------------------------------------------------------------
  static double screenHPadding(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 16, // 24
    medium: 20,
    expanded: 24,
  );

  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: screenHPadding(context),
  );

  // If you want vertical padding too (not always)
  static EdgeInsets screenVPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: screenHPadding(context),
    vertical: adaptiveValue<double>(context, compact: 0, medium: 6, expanded: 8),
  );

  // ---------------------------------------------------------------------------
  // Gaps / spacing scale (use like ELayout.gapMd(context))
  // ---------------------------------------------------------------------------
  static double gapXs(BuildContext context) => adaptiveValue<double>(context, compact: 4, medium: 6, expanded: 8);
  static double gapSm(BuildContext context) => adaptiveValue<double>(context, compact: 8, medium: 10, expanded: 12);
  static double gapMd(BuildContext context) => adaptiveValue<double>(context, compact: 16, medium: 18, expanded: 20);
  static double gapLg(BuildContext context) => adaptiveValue<double>(context, compact: 24, medium: 28, expanded: 32);
  static double gapSection(BuildContext context) => adaptiveValue<double>(context, compact: 32, medium: 34, expanded: 36);

  // ---------------------------------------------------------------------------
  // Grid defaults (language screen, products, etc.)
  // ---------------------------------------------------------------------------
  static int gridColumns(BuildContext context, {int compact = 2, int medium = 3, int expanded = 4}) =>
      adaptiveValue<int>(context, compact: compact, medium: medium, expanded: expanded);

  static double gridGap(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 24,
    medium: 18,
    expanded: 20,
  );

  static double gridChildAspectRatio(BuildContext context, {double compact = 1.0, double medium = 1.15, double expanded = 1.2}) =>
      adaptiveValue<double>(context, compact: compact, medium: medium, expanded: expanded);

  // ---------------------------------------------------------------------------
  // Component sizing defaults (common UI controls)
  // ---------------------------------------------------------------------------
  static double buttonHeight(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 56, // 56
    medium: 56,
    expanded: 58,
  );

  static double radiusMd(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 8, // 8
    medium: 10,
    expanded: 12,
  );

  static double radiusLg(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 12, // 12
    medium: 14,
    expanded: 16,
  );

  static double iconSm(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 16, // 16
    medium: 18,
    expanded: 20,
  );

  static double iconMd(BuildContext context) => adaptiveValue<double>(
    context,
    compact: 24, // 24
    medium: 26,
    expanded: 28,
  );



  // ---------------------------------------------------------------------------
  // Optional: a "touch target" minimum (for accessibility)
  // ---------------------------------------------------------------------------
  static double minTapTarget(BuildContext context) => adaptiveValue<double>(context, compact: 44, medium: 48, expanded: 48);

  // ---------------------------------------------------------------------------
  // If you still want some “design-based” scaling for specific widgets:
  // Keep it isolated and intentional (NOT used everywhere).
  // ---------------------------------------------------------------------------
  static double scaleW(BuildContext context, double value) => value.w(context); // from EUnits
  static double scaleH(BuildContext context, double value) => value.h(context);
  static double scaleR(BuildContext context, double value) => value.r(context);
}