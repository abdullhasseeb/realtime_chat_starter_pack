
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../styles/paddings.dart';

class UPScaffold extends StatelessWidget {
  const UPScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.applyPadding = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.backgroundColor,
    this.useSafeArea = true,
    this.lightToolbarIcons = false,
    this.extendBody = true
  });

  final Widget? body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final bool? resizeToAvoidBottomInset;
  final bool applyPadding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final Color? backgroundColor;
  final bool useSafeArea;
  final bool lightToolbarIcons;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    bool dark = lightToolbarIcons ? true : UPHelperFunctions.isDarkMode(context);
    final bg = backgroundColor ?? (dark ? UPColors.black : UPColors.white);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBody: extendBody,
        backgroundColor: bg,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        body: useSafeArea
            ? SafeArea(
                child: Padding(
                  padding: applyPadding ? UPPadding.screenPadding(context) : EdgeInsets.zero,
                  child: body,
                ),
              )
            : Padding(padding: applyPadding ? UPPadding.screenPadding(context) : EdgeInsets.zero, child: body),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}
