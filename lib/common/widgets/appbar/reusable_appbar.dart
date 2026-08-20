import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/constants/colors.dart';

class UPAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UPAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.centerTitle = false,
    this.backgroundColor,
    this.backArrowColor,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? backArrowColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,

      /// Leading
      leading: showBackArrow
          ? GestureDetector(
        onTap: context.pop,
            child: Icon(
                    Icons.arrow_back,
                    color: backArrowColor ?? UPColors.white,
                  ),
          )
          : leadingIcon != null
          ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
          : null,

      /// Title
      title: title,

      /// Actions
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
