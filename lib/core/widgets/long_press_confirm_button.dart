import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iPhone 잠금화면 카메라 버튼 스타일 롱프레스: 터치 시 1.08배 확대(120ms ease-out), 유지 시 0.3~0.5초 후 실행, 손 뗄 때 180ms ease-in-out 복귀.
/// 짧게 누르면 즉시 onTap. [scaleNotifier]로 현재 스케일 전달해 자식이 역배율/밝기 등 적용 가능.
class LongPressConfirmButton extends StatefulWidget {
  const LongPressConfirmButton({
    super.key,
    required this.onTap,
    this.child,
    this.background,
    this.content,
    this.baseWidth,
    this.baseHeight,
    this.scaleNotifier,
    this.longPressDuration = const Duration(milliseconds: 400),
    this.pressedScale = 1.08,
    this.pressDurationMs = 120,
    this.releaseDurationMs = 180,
  })  : assert(child != null || (background != null && content != null && baseWidth != null && baseHeight != null)),
        assert(child == null || (background == null && content == null));

  final VoidCallback onTap;
  final Widget? child;
  final Widget? background;
  final Widget? content;
  final double? baseWidth;
  final double? baseHeight;
  final ValueNotifier<double>? scaleNotifier;
  final Duration longPressDuration;
  final double pressedScale;
  final int pressDurationMs;
  final int releaseDurationMs;

  @override
  State<LongPressConfirmButton> createState() => _LongPressConfirmButtonState();
}

class _LongPressConfirmButtonState extends State<LongPressConfirmButton>
    with TickerProviderStateMixin {
  Timer? _timer;
  bool _longPressFired = false;
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pressController.dispose();
    super.dispose();
  }

  void _onLongPressComplete() {
    _timer = null;
    if (!mounted) return;
    _longPressFired = true;
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _onTapDown(TapDownDetails details) {
    _longPressFired = false;
    _timer?.cancel();
    _pressController.animateTo(
      1.0,
      duration: Duration(milliseconds: widget.pressDurationMs),
      curve: Curves.easeOut,
    );
    _timer = Timer(widget.longPressDuration, _onLongPressComplete);
  }

  void _onTapUp(TapUpDetails details) {
    _timer?.cancel();
    _timer = null;
    _pressController.animateTo(
      0.0,
      duration: Duration(milliseconds: widget.releaseDurationMs),
      curve: Curves.easeInOut,
    );
  }

  void _onTapCancel() {
    _timer?.cancel();
    _timer = null;
    _pressController.animateTo(
      0.0,
      duration: Duration(milliseconds: widget.releaseDurationMs),
      curve: Curves.easeInOut,
    );
  }

  void _onTap() {
    if (_longPressFired) return;
    widget.onTap();
  }

  double get _effectiveScale {
    return 1.0 + (widget.pressedScale - 1.0) * _pressController.value;
  }

  @override
  Widget build(BuildContext context) {
    final useSplit = widget.background != null && widget.content != null &&
        widget.baseWidth != null && widget.baseHeight != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, _) {
          final scale = _effectiveScale;
          widget.scaleNotifier?.value = scale;
          if (useSplit) {
            final w = widget.baseWidth!;
            final h = widget.baseHeight!;
            return SizedBox(
              width: w * scale,
              height: h * scale,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: w,
                        height: h,
                        child: widget.background,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    height: h,
                    child: widget.content,
                  ),
                ],
              ),
            );
          }
          return Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: widget.child,
          );
        },
      ),
    );
  }
}
