import 'dart:ui';

import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 매칭 탭 우측 하단 자동매치 플로팅 버튼 (접힌 상태: 원형, 펼친 상태: 캡슐).
/// 탭/길게누르 동작은 부모에서 LongPressConfirmButton으로 감싸서 처리.
/// [scaleNotifier]: 부모가 전달하면 커질 때 아이콘/텍스트는 역배율로 원래 크기 유지.
class AutoMatchFab extends StatefulWidget {
  const AutoMatchFab({
    super.key,
    required this.compact,
    this.scaleNotifier,
  });

  final bool compact;
  final ValueNotifier<double>? scaleNotifier;

  @override
  State<AutoMatchFab> createState() => _AutoMatchFabState();
}

class _AutoMatchFabState extends State<AutoMatchFab> {
  @override
  Widget build(BuildContext context) {
    const size = 58.0;
    const radius = 29.0;
    final width = widget.compact ? size : 156.0;
    final height = widget.compact ? size : 58.0;
    final cornerRadius = widget.compact ? radius : 29.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = widget.scaleNotifier;

    Widget buildContent({required double scale}) {
      final pressT = scale > 1.0 ? ((scale - 1.0) / 0.08).clamp(0.0, 1.0) : 0.0;
      final blur = 20.0 + 4.0 * pressT;
      final borderOpacity = isDark ? 0.33 + 0.08 * pressT : 0.66 + 0.12 * pressT;
      final gradientStart = isDark ? 0.33 + 0.06 * pressT : 0.0;
      final gradientEnd = isDark ? 0.11 + 0.05 * pressT : 0.0;
      return ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, borderOpacity.clamp(0.0, 1.0)),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color.fromRGBO(255, 255, 255, gradientStart.clamp(0.0, 1.0)),
                        Color.fromRGBO(234, 242, 250, gradientEnd.clamp(0.0, 1.0)),
                      ]
                    : [
                        Color.fromRGBO(255, 255, 255, (0.7 + 0.08 * pressT).clamp(0.0, 1.0)),
                        Color.fromRGBO(234, 242, 250, (0.4 + 0.06 * pressT).clamp(0.0, 1.0)),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 16 + 2 * pressT,
                  spreadRadius: -4 + pressT,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _wrapContentIfNotifier(
                context,
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: widget.compact
                        ? Icon(
                            Icons.bolt_rounded,
                            key: const ValueKey('compact_bolt'),
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 36,
                            weight: 700,
                          )
                        : Text(
                            '자동매치',
                            key: const ValueKey('expanded_label'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
    }

    final body = notifier != null
        ? ListenableBuilder(
            listenable: notifier,
            builder: (_, __) => buildContent(scale: notifier.value),
          )
        : buildContent(scale: 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      child: body,
    );
  }

  Widget _wrapContentIfNotifier(BuildContext context, Widget content) {
    final notifier = widget.scaleNotifier;
    if (notifier == null) return content;
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final scale = notifier.value;
        if (scale <= 0) return content;
        return Transform.scale(
          scale: 1 / scale,
          alignment: Alignment.center,
          child: content,
        );
      },
    );
  }
}
