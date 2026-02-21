import 'dart:ui';

import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/theme/app_dimensions.dart';
import 'package:clubal_app/core/widgets/liquid_pressable.dart';
import 'package:flutter/material.dart';

/// 글라스 스타일 확인 버튼
class ConfirmButton extends StatelessWidget {
  const ConfirmButton({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.brandColor,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return LiquidPressable(
      onTap: enabled ? onTap : null,
      pressedOpacity: enabled ? 0.74 : 1.0,
      pressedScale: enabled ? 0.96 : 1.0,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: ClipRRect(
          borderRadius: AppDimensions.borderRadiusCard,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.8),
                borderRadius: AppDimensions.borderRadiusCard,
                border: Border.all(
                  color: AppColors.glassBorderDark,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
