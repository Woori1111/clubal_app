import 'package:flutter/material.dart';

/// 터치 스타일: 스프링 팝 vs 단순 scale
enum LiquidPressableStyle {
  /// 눌리면 살짝 줄었다가, 손 떼면 살짝 튀었다가 복원 (스프링 팝)
  spring,
  /// 단순 scale + opacity
  scale,
}

/// 손을 뗄 때 1 → 0으로 가면서 살짝 overshoot (0 아래로) 했다가 0으로 수렴
class _SpringReleaseCurve extends Curve {
  const _SpringReleaseCurve();

  @override
  double transformInternal(double t) {
    if (t >= 1.0) return 0.0;
    // 0~0.5: 1 → -0.12 (overshoot), 0.5~1: -0.12 → 0
    if (t < 0.55) {
      final x = t / 0.55;
      return 1.0 - 1.12 * x; // 1 -> -0.12
    }
    final x = (t - 0.55) / 0.45;
    return -0.12 + 0.12 * x; // -0.12 -> 0
  }
}

const _springReleaseCurve = _SpringReleaseCurve();

class LiquidPressable extends StatefulWidget {
  const LiquidPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
    this.pressedOpacity = 0.85,
    this.duration = const Duration(milliseconds: 120),
    this.style = LiquidPressableStyle.spring,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double pressedOpacity;
  final Duration duration;
  final LiquidPressableStyle style;

  @override
  State<LiquidPressable> createState() => _LiquidPressableState();
}

class _LiquidPressableState extends State<LiquidPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    if (widget.style == LiquidPressableStyle.spring) {
      _controller.forward();
    } else {
      setState(() => _isPressedScale = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    if (widget.style == LiquidPressableStyle.spring) {
      _controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 380),
        curve: _springReleaseCurve,
      );
    } else {
      setState(() => _isPressedScale = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    if (widget.style == LiquidPressableStyle.spring) {
      _controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 380),
        curve: _springReleaseCurve,
      );
    } else {
      setState(() => _isPressedScale = false);
    }
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  bool _isPressedScale = false;

  @override
  Widget build(BuildContext context) {
    if (widget.style == LiquidPressableStyle.spring) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap != null ? _handleTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            // 눌림: 0.97, 손 뗌: 1 + 0.0036까지 overshoot 후 1 (t가 -0.12일 때 1.0036)
            final scale = 1.0 - 0.03 * t;
            return Transform.scale(
              scale: scale.clamp(0.0, 1.1),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: widget.child,
        ),
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap != null ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressedScale ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isPressedScale ? widget.pressedOpacity : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
