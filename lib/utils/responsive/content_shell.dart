
import 'package:flutter/material.dart';
import 'package:realtime_chat/utils/responsive/size_helper.dart';


class UPContentShell extends StatelessWidget {
  const UPContentShell({
    super.key,
    required this.child,
    this.maxWidthCompact = double.infinity,
    this.maxWidthMedium = 560,
    this.maxWidthExpanded = 720,
  });

  final Widget child;
  final double maxWidthCompact;
  final double maxWidthMedium;
  final double maxWidthExpanded;

  @override
  Widget build(BuildContext context) {
    final sizeClass = context.sizeClass;

    final maxW = switch (sizeClass) {
      UPSizeClass.compact => maxWidthCompact,
      UPSizeClass.medium => maxWidthMedium,
      UPSizeClass.expanded => maxWidthExpanded,
    };

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }
}