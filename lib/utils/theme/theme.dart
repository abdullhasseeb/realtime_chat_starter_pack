import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realtime_chat/utils/theme/widgets_theme/filled_button_theme.dart';
import 'package:realtime_chat/utils/theme/widgets_theme/icon_theme.dart';
import 'package:realtime_chat/utils/theme/widgets_theme/text_button_theme.dart';
import 'package:realtime_chat/utils/theme/widgets_theme/text_field_theme.dart';
import 'package:realtime_chat/utils/theme/widgets_theme/text_theme.dart';
import '../constants/colors.dart';

class UPAppTheme {
  UPAppTheme._();

  static ThemeData lightTheme = () {
    final colorScheme = ColorScheme.fromSeed(seedColor: UPColors.primary, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: UPColors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: UPTextFieldTheme.light,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: UPColors.primary,
        selectionHandleColor: UPColors.primary,
        selectionColor: UPColors.primaryDark,
      ),
      textTheme: UPTextTheme.lightTextTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
      filledButtonTheme: UPFilledButtonTheme.light(colorScheme, UPTextTheme.lightTextTheme),
      textButtonTheme: UPTextButtonTheme.light(colorScheme, UPTextTheme.lightTextTheme),
      iconTheme: UPIconTheme.lightTheme,
    );
  }();

  static ThemeData darkTheme = () {
    final colorScheme = ColorScheme.fromSeed(seedColor: UPColors.primary, brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: UPColors.black,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: UPTextFieldTheme.dark,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: UPColors.primary,
        selectionHandleColor: UPColors.primary,
        selectionColor: UPColors.primaryDark,
      ),
      textTheme: UPTextTheme.darkTextTheme.apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
      appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
      filledButtonTheme: UPFilledButtonTheme.dark(colorScheme, UPTextTheme.darkTextTheme),
      textButtonTheme: UPTextButtonTheme.dark(colorScheme, UPTextTheme.darkTextTheme),
      iconTheme: UPIconTheme.darkTheme,
    );
  }();
}
