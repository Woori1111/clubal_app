import 'package:flutter/material.dart';

class ClubalBackground extends StatelessWidget {
  const ClubalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FBFF), Color(0xFFEFF4FA)],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            left: -70,
            top: -40,
            child: _GlowBubble(size: 230, color: Color(0x8066C8FF)),
          ),
          Positioned(
            right: -110,
            top: 220,
            child: _GlowBubble(size: 280, color: Color(0x555E86FF)),
          ),
          Positioned(
            left: 40,
            bottom: 150,
            child: _GlowBubble(size: 180, color: Color(0x665CFFD7)),
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
