import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGlassStyles {
  const AppGlassStyles._();

  static BoxDecoration card({double radius = 16, EdgeInsets? padding}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xB3FFFFFF),
          Color(0x66FFFFFF),
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 20,
          spreadRadius: -5,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration innerCard({double radius = 12}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0x4DFFFFFF), width: 1),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x80FFFFFF),
          Color(0x33FFFFFF),
        ],
      ),
    );
  }
}

