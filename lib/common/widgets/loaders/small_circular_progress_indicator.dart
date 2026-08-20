import 'package:flutter/material.dart';

class SmallCircularProgressIndicator extends StatelessWidget {
  const SmallCircularProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2));
  }
}