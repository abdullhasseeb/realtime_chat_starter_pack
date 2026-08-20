
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../containers/rounded_container.dart';

class UPTextField extends StatelessWidget {
  const UPTextField({
    super.key,
    required this.controller,
    this.validator,
    this.obscureText,
    this.textCapitalization,
    this.maxLines,
    this.keyboardType,
    this.onFieldSubmitted,
    this.textInputAction,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.focusNode,
    this.enabled,
    this.minLines
  });

  final TextEditingController controller;
  final FormFieldValidator<String?>? validator;
  final bool? obscureText;
  final TextCapitalization? textCapitalization;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Function(String? value)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final Function(String value)? onChanged;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool? enabled;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    bool isDark = UPHelperFunctions.isDarkMode(context);
    return UPRoundedContainer(
      backgroundColor: isDark ? UPColors.darkerGrey : UPColors.fieldBackground,
      child: TextFormField(
        minLines: minLines,
        enabled: enabled,
        controller: controller,
        validator: validator,
        obscureText: obscureText ?? false,
        textCapitalization: textCapitalization ?? TextCapitalization.words,
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        onChanged: onChanged,
        autofillHints: autofillHints,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
