
import 'package:flutter/material.dart';

class AppTextResponsive extends StatelessWidget {
  const AppTextResponsive({
    super.key,
    required this.child,
    this.minScaleFactor = 0.90,
    this.maxScaleFactor = 1.20,
  });

  final Widget child;
  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) {


    // clamp user accessibility scaling
    final clampedChild = MediaQuery.withClampedTextScaling(
      minScaleFactor: minScaleFactor,
      maxScaleFactor: maxScaleFactor,
      child: child,
    );

    return clampedChild;
  }
}