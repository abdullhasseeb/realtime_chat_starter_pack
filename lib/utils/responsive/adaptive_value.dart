import 'package:flutter/material.dart';
import 'size_helper.dart';

/// Returns different values based on size class.
/// Great for padding, gaps, columns, icon sizes, etc.
T adaptiveValue<T>(
    BuildContext context, {
      required T compact,
      T? medium,
      T? expanded,
    }) {
  final m = medium ?? compact;
  final e = expanded ?? m;

  return switch (context.sizeClass) {
    UPSizeClass.compact => compact,
    UPSizeClass.medium => m,
    UPSizeClass.expanded => e,
  };
}