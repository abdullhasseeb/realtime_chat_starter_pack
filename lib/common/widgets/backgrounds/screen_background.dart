import 'dart:math';

import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';

class UPScreenBackground extends StatelessWidget {
  const UPScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    bool isDark = UPHelperFunctions.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [UPColors.gradientTop, UPColors.gradientMiddle, UPColors.gradientBottom]
              : const [UPColors.gradientLightTop, UPColors.gradientLightMiddle, UPColors.gradientLightBottom],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // subtle particle dots
          const _StarParticles(),
          child,
        ],
      ),
    );
  }
}

// Star particles
class _StarParticles extends StatelessWidget {
  const _StarParticles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter(), size: Size.infinite);
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final random = Random(42); // fixed seed = same stars every build

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2 + 0.3;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
