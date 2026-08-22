import 'package:flutter/material.dart';
import 'size_helper.dart';

/// Picks a widget based on current size class.
/// - compact  => phone
/// - medium   => small tablet
/// - expanded => large tablet
class UPAdaptive extends StatelessWidget {
  const UPAdaptive({
    super.key,
    required this.compact,
    Widget? medium,
    Widget? expanded,
  })  : medium = medium ?? compact,
        expanded = expanded ?? medium ?? compact;

  final Widget compact;
  final Widget medium;
  final Widget expanded;

  @override
  Widget build(BuildContext context) {
    return switch (context.sizeClass) {
      UPSizeClass.compact => compact,
      UPSizeClass.medium => medium,
      UPSizeClass.expanded => expanded,
    };
  }
}