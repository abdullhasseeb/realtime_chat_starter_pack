import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

class UPCircularContainer extends StatelessWidget {
  const UPCircularContainer({
    super.key,
    this.height,
    this.width,
    this.backgroundColor = UPColors.white,
    this.padding,
    this.margin,
    this.child,
    this.boxShadow,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.animationDuration = 0,
    this.animationCurve = Curves.easeOutCubic,
    this.borderWidth,
    this.onTap,
  });

  final double? height, width;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding, margin;
  final Widget? child;
  final List<BoxShadow>? boxShadow;
  final bool showBorder;
  final Color borderColor;
  final int animationDuration;
  final Curve animationCurve;
  final double? borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: animationDuration),
        curve: animationCurve,
        height: height,
        width: width,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1000),
          color: backgroundColor,
          boxShadow: boxShadow,
          border: showBorder
              ? Border.all(color: borderColor, width: borderWidth ?? 1.0)
              : null,
        ),
        child: child,
      ),
    );
  }
}
