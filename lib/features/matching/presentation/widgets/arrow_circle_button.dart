import 'package:clubal_app/core/widgets/liquid_pressable.dart';
import 'package:flutter/material.dart';

/// 인원수 조절용 ◀/▶ 스타일 버튼 (투명 배경)
class ArrowCircleButton extends StatelessWidget {
  const ArrowCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return LiquidPressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: IgnorePointer(
        child: IconButton(
          onPressed: null,
          icon: Icon(icon, color: onSurface),
          style: IconButton.styleFrom(
            minimumSize: const Size(42, 42),
            backgroundColor: Colors.transparent,
            foregroundColor: onSurface,
          ),
        ),
      ),
    );
  }
}
