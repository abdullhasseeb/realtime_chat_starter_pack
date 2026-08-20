import 'package:flutter/material.dart';

import '../constants/app_messenger.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import 'helper_functions.dart';

enum SnackType { success, error, warning, info }

class SnackBarHelper {
  SnackBarHelper._();

  /// Main function to show message
  static void show({
    required String message,
    SnackType type = SnackType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messengerState = AppMessenger.key.currentState;
    if (messengerState == null) return;

    messengerState.clearSnackBars();

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          _icon(messengerState.context, type),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
      backgroundColor: _bgColor(messengerState.context, type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UPSizes.borderRadiusLg)),
    );

    messengerState.showSnackBar(snackBar);
  }

  /// Success Message
  static void success(String message) =>
      show(message: message, type: SnackType.success, duration: const Duration(seconds: 2));

  /// Error Message
  static void error(String message) =>
      show(message: message, type: SnackType.error, duration: const Duration(seconds: 4));

  /// Warning Message
  static void warning(String message) => show(message: message, type: SnackType.warning);

  /// SnackBar Bar Icon
  static Widget _icon(BuildContext context, SnackType type) {
    bool isDark = UPHelperFunctions.isDarkMode(context);
    Color color = isDark ? Colors.black : Colors.white;
    switch (type) {
      case SnackType.success:
        return Icon(Icons.check_circle_outline, size: 18, color: color);
      case SnackType.error:
        return Icon(Icons.error_outline, size: 18, color: color);
      case SnackType.warning:
        return Icon(Icons.warning_amber_outlined, size: 18, color: color);
      case SnackType.info:
        return Icon(Icons.info_outline, size: 18, color: color);
    }
  }

  /// Background Color of snackBar
  static Color _bgColor(BuildContext context, SnackType type) {
    switch (type) {
      case SnackType.success:
        return UPColors.success;
      case SnackType.error:
        return UPColors.error;
      case SnackType.warning:
        return UPColors.warning;
      case SnackType.info:
        return UPColors.info;
    }
  }
}
