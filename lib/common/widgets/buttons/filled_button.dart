import 'package:flutter/material.dart';

import '../loaders/small_circular_progress_indicator.dart';

class UPFilledButton extends StatelessWidget {
  const UPFilledButton({super.key, required this.label, required this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const SmallCircularProgressIndicator() : Text(label),
    );
  }
}
