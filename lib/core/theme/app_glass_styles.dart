import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGlassStyles {
  const AppGlassStyles._();

  static BoxDecoration card({double radius = 16, EdgeInsets? padding}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
      // 배경은 더 투명하게 빼서 블러(Blur) 왜곡 효과가 잘 보이게 함
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x99FFFFFF), // 60% 흰색
          Color(0x33FFFFFF), // 20% 흰색
        ],
      ),
      // 짙고 퍼지는 남색 계열 그림자로 배경과 카드 사이의 입체감 확보
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A2A3D54),
          blurRadius: 24,
          spreadRadius: -4,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration innerCard({double radius = 12}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0x4DFFFFFF), width: 1.0),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x66FFFFFF),
          Color(0x1AFFFFFF),
        ],
      ),
    );
  }
}

