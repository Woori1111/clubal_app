import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class ClubalTopTabBar extends StatefulWidget {
  const ClubalTopTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<ClubalTopTabBar> createState() => _ClubalTopTabBarState();
}

class _ClubalTopTabBarState extends State<ClubalTopTabBar> {
  int? _interactionIndex;
  double? _interactionDx;
  bool _isInteracting = false;
  double _travelDirection = 0;
  final Map<int, double> _buttonPressScale = {}; // 각 버튼의 눌림 스케일
  int _fireAnimationKey = 0; // 인기 탭 불 아이콘 애니메이션 트리거

  int _indexFromLocalDx(double dx, double width) {
    if (widget.tabs.isEmpty || width <= 0) {
      return 0;
    }
    final clampedDx = dx.clamp(0.0, width - 0.001);
    final itemWidth = width / widget.tabs.length;
    if (itemWidth.isNaN || itemWidth.isInfinite || itemWidth <= 0) {
      return 0;
    }
    final index = (clampedDx / itemWidth).floor();
    return index.clamp(0, widget.tabs.length - 1);
  }

  double _centerDxForIndex(int index, double itemWidth) {
    if (itemWidth.isNaN || itemWidth.isInfinite || itemWidth <= 0) {
      return 0.0;
    }
    final safeIndex = index.clamp(0, widget.tabs.isEmpty ? 0 : widget.tabs.length - 1);
    return (itemWidth * safeIndex) + (itemWidth / 2);
  }

  void _startInteraction(int index, double itemWidth) {
    if (widget.tabs.isEmpty || index < 0 || index >= widget.tabs.length) {
      return;
    }
    if (itemWidth.isNaN || itemWidth.isInfinite || itemWidth <= 0) {
      return;
    }
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (index - previous).toDouble().sign;
    setState(() {
      _interactionIndex = index;
      _interactionDx = _centerDxForIndex(index, itemWidth);
      _isInteracting = true;
      _travelDirection = direction;
      _buttonPressScale[index] = 0.85; // 눌림 시 스케일 감소
      if (widget.tabs[index] == '인기') {
        _fireAnimationKey++; // 인기 탭: 불 아이콘 애니메이션
      }
    });
    widget.onChanged(index);
    
    // gooey 효과를 위한 애니메이션
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _buttonPressScale[index] = 1.0;
        });
      }
    });
  }

  void _updateInteractionByDx(double dx, double width) {
    // 원인 1: dx, width NaN 체크
    if (dx.isNaN || dx.isInfinite || width.isNaN || width.isInfinite || width <= 0) {
      return;
    }
    final index = _indexFromLocalDx(dx, width);
    if (_interactionIndex == index && _isInteracting) {
      return;
    }
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (index - previous).toDouble().sign;
    final clampedDx = dx.clamp(0.0, width);
    if (clampedDx.isNaN || clampedDx.isInfinite) {
      return;
    }
    setState(() {
      _interactionIndex = index;
      _interactionDx = clampedDx;
      _isInteracting = true;
      _travelDirection = direction;
    });
    widget.onChanged(index);
  }

  void _endInteraction() {
    setState(() {
      _isInteracting = false;
      _interactionIndex = null;
      _interactionDx = null;
      _travelDirection = 0;
      _buttonPressScale.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const sidePadding = 8.0;
    final activeIndex = _interactionIndex ?? widget.selectedIndex;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x55FFFFFF), width: 1.2),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x4DF3FAFF), Color(0x33A7B7FF)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (widget.tabs.isEmpty) {
                return const SizedBox.shrink();
              }
              final navWidth = constraints.maxWidth - (sidePadding * 2);
              if (navWidth <= 0) {
                return const SizedBox.shrink();
              }
              final itemWidth = navWidth / widget.tabs.length;
              if (itemWidth.isNaN || itemWidth.isInfinite || itemWidth <= 0) {
                return const SizedBox.shrink();
              }
              final lensWidth = itemWidth * 0.96;
              // 원인 5: lensWidth NaN 체크
              if (lensWidth.isNaN || lensWidth.isInfinite || lensWidth <= 0) {
                return const SizedBox.shrink();
              }
              final safeActiveIndex = activeIndex.clamp(0, widget.tabs.length - 1);
              final restingLensLeftCalc = sidePadding +
                  (itemWidth * safeActiveIndex) +
                  (itemWidth - lensWidth) / 2;
              // restingLensLeft NaN 체크
              final restingLensLeft = restingLensLeftCalc.isNaN || restingLensLeftCalc.isInfinite
                  ? sidePadding
                  : restingLensLeftCalc;
              
              // 원인 2: _interactionDx NaN 체크
              double interactionDxValue;
              if (_interactionDx != null && !_interactionDx!.isNaN && !_interactionDx!.isInfinite) {
                interactionDxValue = _interactionDx!;
              } else {
                interactionDxValue = _centerDxForIndex(safeActiveIndex, itemWidth);
              }
              // interactionDxValue NaN 재확인
              if (interactionDxValue.isNaN || interactionDxValue.isInfinite) {
                interactionDxValue = _centerDxForIndex(safeActiveIndex, itemWidth);
              }
              
              final dragLensLeftCalc = sidePadding +
                  (interactionDxValue - (lensWidth / 2))
                      .clamp(0.0, navWidth - lensWidth);
              // dragLensLeft NaN 체크
              final dragLensLeft = dragLensLeftCalc.isNaN || dragLensLeftCalc.isInfinite
                  ? restingLensLeft
                  : dragLensLeftCalc;
              
              // 원인 3: lensLeft NaN 체크
              final lensLeft = _isInteracting ? dragLensLeft : restingLensLeft;
              final safeLensLeft = lensLeft.isNaN || lensLeft.isInfinite 
                  ? restingLensLeft 
                  : lensLeft.clamp(0.0, navWidth);

              return _ClubalTopTabBarContent(
                sidePadding: sidePadding,
                lensWidth: lensWidth,
                navWidth: navWidth,
                isInteracting: _isInteracting,
                travelDirection: _travelDirection,
                safeLensLeft: safeLensLeft,
                tabs: widget.tabs,
                selectedIndex: widget.selectedIndex,
                interactionIndex: _interactionIndex,
                buttonPressScale: _buttonPressScale,
                fireAnimationKey: _fireAnimationKey,
                onDragUpdateDx: (dx) => _updateInteractionByDx(dx, navWidth),
                onDragEnd: _endInteraction,
                onPressedTab: (i) => _startInteraction(i, itemWidth),
                onTapTab: (i) {
                  widget.onChanged(i);
                  _endInteraction();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ClubalTopTabBarContent extends StatelessWidget {
  const _ClubalTopTabBarContent({
    required this.sidePadding,
    required this.lensWidth,
    required this.navWidth,
    required this.isInteracting,
    required this.travelDirection,
    required this.safeLensLeft,
    required this.tabs,
    required this.selectedIndex,
    required this.interactionIndex,
    required this.buttonPressScale,
    required this.fireAnimationKey,
    required this.onDragUpdateDx,
    required this.onDragEnd,
    required this.onPressedTab,
    required this.onTapTab,
  });

  final double sidePadding;
  final double lensWidth;
  final double navWidth;
  final bool isInteracting;
  final double travelDirection;
  final double safeLensLeft;
  final List<String> tabs;
  final int selectedIndex;
  final int? interactionIndex;
  final Map<int, double> buttonPressScale;
  final int fireAnimationKey;
  final ValueChanged<double> onDragUpdateDx;
  final VoidCallback onDragEnd;
  final ValueChanged<int> onPressedTab;
  final ValueChanged<int> onTapTab;

  @override
  Widget build(BuildContext context) {
    final lens = _TabLens(
      width: lensWidth,
      isInteracting: isInteracting,
      travelDirection: travelDirection,
    );

    return Stack(
      children: [
        AnimatedPositioned(
          duration: isInteracting
              ? Duration.zero
              : const Duration(milliseconds: 650),
          curve: isInteracting ? Curves.linear : Curves.elasticOut,
          left: safeLensLeft,
          top: 4,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            scale: isInteracting ? 1.08 : 1.0,
            child: lens,
          ),
        ),
        Positioned.fill(
          left: sidePadding,
          right: sidePadding,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) =>
                onDragUpdateDx(details.localPosition.dx),
            onHorizontalDragUpdate: (details) =>
                onDragUpdateDx(details.localPosition.dx),
            onHorizontalDragEnd: (_) => onDragEnd(),
            onHorizontalDragCancel: onDragEnd,
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _TabButton(
                      label: tabs[i],
                      selected: i == selectedIndex,
                      pressScale: buttonPressScale[i] ?? 1.0,
                      fireAnimationKey:
                          tabs[i] == '인기' ? fireAnimationKey : null,
                      onTapDown: () => onPressedTab(i),
                      onTap: () => onTapTab(i),
                      onTapCancel: onDragEnd,
                      onTapUp: onDragEnd,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.pressScale,
    this.fireAnimationKey,
    required this.onTapDown,
    required this.onTap,
    required this.onTapUp,
    required this.onTapCancel,
  });

  final String label;
  final bool selected;
  final double pressScale;
  final int? fireAnimationKey;
  final VoidCallback onTapDown;
  final VoidCallback onTap;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  @override
  Widget build(BuildContext context) {
    final fgColor = selected
        ? const Color(0xFFF5FCFF)
        : const Color(0xB3DCEAFF);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onTapDown(),
        onTapUp: (_) => onTapUp(),
        onTapCancel: onTapCancel,
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.elasticOut,
          scale: pressScale,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fgColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (label == '인기') ...[
                  const SizedBox(width: 4),
                  _FireIcon(
                    color: fgColor,
                    animationKey: fireAnimationKey,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 인기 탭 불 아이콘 — 클릭 시 화르륵 타는 애니메이션
class _FireIcon extends StatelessWidget {
  const _FireIcon({
    required this.color,
    this.animationKey,
  });

  final Color color;
  final int? animationKey;

  @override
  Widget build(BuildContext context) {
    final key = animationKey;
    if (key == null || key <= 0) {
      return Icon(
        Icons.local_fire_department_rounded,
        color: color,
        size: 18,
      );
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey(key),
      duration: const Duration(milliseconds: 420),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, t, _) {
        final clampedT = t.clamp(0.0, 1.0);
        
        // 1. 세로(scaleY)만 더 늘어나도록: 초반 빠르게 커지고 후반 줄어듦
        final scaleY = clampedT < 0.3
            ? 1.0 + (clampedT / 0.3) * 0.8  // 0 → 0.3: 1.0 → 1.8
            : 1.8 - ((clampedT - 0.3) / 0.7) * 0.8;  // 0.3 → 1.0: 1.8 → 1.0
        final safeScaleY = scaleY.isNaN || scaleY.isInfinite ? 1.0 : scaleY.clamp(0.8, 2.0);
        
        // 2. 애니메이션 초반에 밝기 증가 (노란색으로 보간)
        final brightnessFactor = clampedT < 0.4
            ? 1.0 - (clampedT / 0.4) * 0.6  // 초반에 밝게 (0.4 → 1.0)
            : 0.4 + ((clampedT - 0.4) / 0.6) * 0.6;  // 후반에 원래대로 (0.4 → 1.0)
        final fireColor = Color.lerp(
          color,
          const Color(0xFFFFD700),  // 노란색
          (1.0 - brightnessFactor) * 0.5,  // 최대 50% 노란색으로 보간
        ) ?? color;
        
        // 3. BoxShadow 글로우 효과 (blurRadius가 커졌다가 줄어듦)
        final glowIntensity = clampedT < 0.35
            ? clampedT / 0.35  // 0 → 0.35: 0 → 1
            : 1.0 - ((clampedT - 0.35) / 0.65);  // 0.35 → 1.0: 1 → 0
        final blurRadius = 4.0 + glowIntensity * 8.0;  // 4 → 12 → 4
        final shadowColor = Color.lerp(
          Colors.transparent,
          const Color(0x80FFA500),  // 오렌지색 글로우
          glowIntensity * 0.7,
        ) ?? Colors.transparent;
        
        // 4. 미세한 좌우 흔들림 (sin 기반 rotate)
        final shakeAmount = clampedT < 0.5
            ? (clampedT / 0.5) * 0.15  // 초반에 흔들림 증가
            : 0.15 - ((clampedT - 0.5) / 0.5) * 0.15;  // 후반에 감소
        final rotation = shakeAmount * math.sin(clampedT * 20) * 0.1;  // -0.015 ~ +0.015 라디안 (약 -0.86도 ~ +0.86도)
        
        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scaleX: 1.0,
            scaleY: safeScaleY,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: blurRadius,
                    spreadRadius: glowIntensity * 2.0,
                  ),
                ],
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: fireColor,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabLens extends StatelessWidget {
  const _TabLens({
    required this.width,
    required this.isInteracting,
    required this.travelDirection,
  });

  final double width;
  final bool isInteracting;
  final double travelDirection;

  @override
  Widget build(BuildContext context) {
    // 원인 5: width NaN 체크
    final safeWidth = width.isNaN || width.isInfinite || width <= 0 ? 0.0 : width;
    if (!isInteracting) {
      return Container(
        width: safeWidth,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9AE1FF), Color(0xFF69C6F6)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5522B8FF),
              blurRadius: 12,
              spreadRadius: -6,
              offset: Offset(0, 4),
            ),
          ],
        ),
      );
    }

    final leadingBoost = travelDirection < 0 ? 1.0 : 0.56;
    final trailingBoost = travelDirection > 0 ? 1.0 : 0.56;

    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: safeWidth,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x35FFFFFF), Color(0x10FFFFFF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 14,
                spreadRadius: -6,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 2,
                left: safeWidth * 0.18,
                right: safeWidth * 0.18,
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0x00FFFFFF),
                        Colors.white.withValues(alpha: 0.52),
                        const Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -6,
                top: 4,
                child: _LensEdgeGlow(size: 36, strength: leadingBoost),
              ),
              Positioned(
                right: -6,
                top: 4,
                child: _LensEdgeGlow(size: 36, strength: trailingBoost),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensEdgeGlow extends StatelessWidget {
  const _LensEdgeGlow({required this.size, required this.strength});

  final double size;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final alpha = 0.42 * strength;
    final coreAlpha = 0.34 * strength;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: coreAlpha),
            const Color(0x66DDF6FF).withValues(alpha: alpha),
            Colors.transparent,
          ],
          stops: const [0.12, 0.52, 1.0],
        ),
      ),
    );
  }
}
