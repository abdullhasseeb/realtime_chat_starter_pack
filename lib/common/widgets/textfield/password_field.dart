
import 'package:flutter/material.dart';
import 'package:realtime_chat/common/widgets/textfield/textfield.dart';

import '../../../utils/validators/validators.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return UPTextField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      hintText: 'Enter your password',
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
      ),
      validator: UPFieldValidators.password
    );
  }
}
