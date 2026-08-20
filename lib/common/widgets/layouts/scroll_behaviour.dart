import 'package:flutter/material.dart';

class UPScrollBehaviour extends ScrollBehavior{

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}