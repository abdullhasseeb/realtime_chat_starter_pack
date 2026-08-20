import 'package:flutter/material.dart';

class HomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    double curveSize = 40;
    double height = size.height;
    double width = size.width;

    path.lineTo(0, height);


    path.quadraticBezierTo(
        0, height - curveSize,
        curveSize, height - curveSize
    );

    path.lineTo(width - curveSize, height - curveSize);

    path.quadraticBezierTo(
        width, height - curveSize,
        width, height
    );

    path.lineTo(width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}