

import 'package:flutter/material.dart';

class UPShadows {

  static List<BoxShadow> navBarShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}