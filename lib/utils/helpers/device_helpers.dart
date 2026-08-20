import 'package:flutter/material.dart';

class UPDeviceHelpers {
  static double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  static double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).height;

  static double get bottomNavHeight => kBottomNavigationBarHeight;
}
