import 'dart:ui';

import 'package:clubal_app/features/navigation/models/nav_tab.dart';
import 'package:flutter/material.dart';

class ClubalJellyBottomNav extends StatefulWidget {
  const ClubalJellyBottomNav({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<ClubalJellyBottomNav> createState() => _ClubalJellyBottomNavState();
}

class _ClubalJellyBottomNavState extends State<ClubalJellyBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(
      widget.tabs.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      ),
    );
    _scaleAnimations = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 22),
        TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.86), weight: 26),
        TweenSequenceItem(tween: Tween(begin: 0.86, end: 1.10), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.10, end: 0.97), weight: 12),
        TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.00), weight: 10),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.linear));
    }).toList();

    _bounceControllers[widget.selectedIndex].forward();
  }

  @override
  void didUpdateWidget(covariant ClubalJellyBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _bounceControllers[widget.selectedIndex].forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SizedBox(
        height: 74,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(37),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(37),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x36FFFFFF), Color(0x1CFFFFFF)],
                ),
                border: Border.all(
                  color: const Color(0x55FFFFFF),
                  width: 0.9,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 30,
                    spreadRadius: -8,
                    offset: Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _JellyBottomNavContent(
                tabs: widget.tabs,
                selectedIndex: widget.selectedIndex,
                scaleAnimations: _scaleAnimations,
                bounceControllers: _bounceControllers,
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JellyBottomNavContent extends StatelessWidget {
  const _JellyBottomNavContent({
    required this.tabs,
    required this.selectedIndex,
    required this.scaleAnimations,
    required this.bounceControllers,
    required this.onChanged,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final List<Animation<double>> scaleAnimations;
  final List<AnimationController> bounceControllers;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _RainbowLensBorderPainter(),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  bounceControllers[i].forward(from: 0);
                  if (i != selectedIndex) {
                    onChanged(i);
                  }
                },
                child: AnimatedBuilder(
                  animation: scaleAnimations[i],
                  builder: (context, _) => _LiquidGlassNavItem(
                    tab: tabs[i],
                    isSelected: i == selectedIndex,
                    bounceScale: scaleAnimations[i].value,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiquidGlassNavItem extends StatelessWidget {
  const _LiquidGlassNavItem({
    required this.tab,
    required this.isSelected,
    required this.bounceScale,
  });

  final NavTab tab;
  final bool isSelected;
  final double bounceScale;

  @override
  Widget build(BuildContext context) {
    // 비활성: 중립 회색 / 활성: 짙은 검정
    final iconColor =
        isSelected ? const Color(0xFF1C1C1E) : const Color(0xFFA0A0A5);
    final labelColor =
        isSelected ? const Color(0xFF1C1C1E) : const Color(0xFFA0A0A5);

    return Center(
      child: Transform.scale(
        scale: bounceScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0x38FFFFFF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(
                        color: const Color(0x50FFFFFF),
                        width: 0.8,
                      )
                    : null,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                tab.icon,
                color: iconColor,
                size: 12.0, // 활성·비활성 동일 크기 (이전 22dp의 절반)
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: labelColor,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: isSelected ? 0.1 : 0.0,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _RainbowLensBorderPainter extends CustomPainter {
  const _RainbowLensBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outer = RRect.fromRectAndRadius(
      rect.deflate(0.8),
      const Radius.circular(37),
    );

    final rainbow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..shader = const SweepGradient(
        colors: [
          Color(0x00FFFFFF),
          Color(0x30FF5E5E),
          Color(0x30FFBE5E),
          Color(0x30FFF56A),
          Color(0x305CFFC5),
          Color(0x3063B8FF),
          Color(0x309977FF),
          Color(0x30FF78D8),
          Color(0x00FFFFFF),
        ],
        stops: [0.0, 0.08, 0.2, 0.32, 0.46, 0.6, 0.72, 0.86, 1.0],
      ).createShader(rect);
    canvas.drawRRect(outer, rainbow);
  }

  @override
  bool shouldRepaint(covariant _RainbowLensBorderPainter oldDelegate) =>
      false;
}
