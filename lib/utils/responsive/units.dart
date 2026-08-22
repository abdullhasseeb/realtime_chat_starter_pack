// lib/responsive/e_units.dart
import 'package:flutter/material.dart';

class UPUnits {
  static const designW = 390.0;
  static const designH = 812.0;
}

extension UPUnitsNumX on num {
  double w(BuildContext context) => (this * MediaQuery.sizeOf(context).width) / UPUnits.designW;
  double h(BuildContext context) => (this * MediaQuery.sizeOf(context).height) / UPUnits.designH;

  // radius/icons scale (average)
  double sp(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    final wScale = s.width / UPUnits.designW;
    final hScale = s.height / UPUnits.designH;
    final avg = (wScale + hScale) / 2;
    return this * avg.clamp(0.85, 1.2);
  }

  double r(BuildContext context) => sp(context); // same idea for radius
}