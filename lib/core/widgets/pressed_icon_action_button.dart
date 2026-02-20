import 'dart:ui';

import 'package:flutter/material.dart';

class PressedIconActionButton extends StatefulWidget {
  const PressedIconActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  State<PressedIconActionButton> createState() =>
      _PressedIconActionButtonState();
}

class _PressedIconActionButtonState extends State<PressedIconActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.92 : 1.0;
    final opacity = _pressed ? 0.72 : 1.0;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(https://github.com/Woori1111/clubal_app/pull/11/conflict?name=lib%252Fcore%252Fwidgets%252Fpressed_icon_action_button.dart&ancestor_oid=05f20b2ecf6f62e1fbb4fa929d697f73e924e5c3&base_oid=f5123de4940febbd0f35e83414ab950a4675df7d&head_oid=a168a3d0ac37489ab597e962299bd743eebe92f8
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0x66FFFFFF),
                    border: Border.all(
                      color: const Color(0x4DFFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: const Color(0xFFE9F6FF),
                    size: 26,
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
