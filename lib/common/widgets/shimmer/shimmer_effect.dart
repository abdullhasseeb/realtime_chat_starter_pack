import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class UPShimmerEffect extends StatelessWidget {
  final double? width, height;
  final double radius;
  final Color? color;

  const UPShimmerEffect({super.key, this.width, this.height, this.radius = UPSizes.borderRadiusLg, this.color});

  @override
  Widget build(BuildContext context) {
    final dark = UPHelperFunctions.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[800]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (dark ? UPColors.darkerGrey : UPColors.white),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
