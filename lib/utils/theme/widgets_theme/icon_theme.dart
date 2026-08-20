import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class UPIconTheme {
  UPIconTheme._();

  static const IconThemeData lightTheme = IconThemeData(size: UPSizes.iconMd, color: UPColors.dark);

  static const IconThemeData darkTheme = IconThemeData(size: UPSizes.iconMd, color: UPColors.light);
}
