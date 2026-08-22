
import 'package:flutter/material.dart';

enum UPSizeClass { compact, medium, expanded }

class UPBreakpoints {
  // Common breakpoints used across Flutter/Material samples
  static const double medium = 600;   // tablet-ish
  static const double expanded = 840; // large tablet

  static UPSizeClass of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= expanded) return UPSizeClass.expanded;
    if (w >= medium) return UPSizeClass.medium;
    return UPSizeClass.compact;
  }
}

extension UPSizeClassX on BuildContext {
  UPSizeClass get sizeClass => UPBreakpoints.of(this);

  bool get isPhone => sizeClass == UPSizeClass.compact;
  bool get isTablet => sizeClass != UPSizeClass.compact;
}