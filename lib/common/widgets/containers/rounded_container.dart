import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class UPRoundedContainer extends StatelessWidget {
  const UPRoundedContainer({
    super.key,
    this.width,
    this.height,
    this.radius = UPSizes.cardRadiusMd,
    this.child,
    this.showBorder = false,
    this.borderColor = UPColors.white,
    this.backgroundColor = Colors.transparent,
    this.padding,
    this.margin,
    this.animationDuration = 0,
    this.animationCurve = Curves.easeOutCubic,
    this.onTap,
    this.borderRadius,
    this.borderWidth = 1,
    this.boxShadow
  });

  final double? width, height;
  final double radius;
  final Widget? child;
  final bool showBorder;
  final Color borderColor, backgroundColor;
  final EdgeInsetsGeometry? padding, margin;
  final int animationDuration;
  final Curve animationCurve;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: animationDuration),
        curve: animationCurve,
        width: width,
        // default 0
        height: height,
        // default 0
        padding: padding,
        // default 0
        margin: margin,
        // default 0
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          border: showBorder ? Border.all(color: borderColor, width: borderWidth) : null,
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}
