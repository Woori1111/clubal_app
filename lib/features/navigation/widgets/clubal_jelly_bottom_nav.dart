import 'dart:async';
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

class _ClubalJellyBottomNavState extends State<ClubalJellyBottomNav> {
  int? _interactionIndex;
  double? _interactionDx;
  double _travelDirection = 0;
  double _motion = 0;
  double _lastDx = 0;
  int _lastMicros = 0;
  bool _isInteracting = false;
  bool _isTransitioning = false;
  bool _releasePop = false;

  Timer? _transitionTimer;
  Timer? _releaseTimer;

  int _indexFromLocalDx(double dx, double width) {
    final clampedDx = dx.clamp(0.0, width - 0.001);
    final itemWidth = width / widget.tabs.length;
    final index = (clampedDx / itemWidth).floor();
    return index.clamp(0, widget.tabs.length - 1);
  }

  double _centerDxForIndex(int index, double itemWidth) {
    return (itemWidth * index) + (itemWidth / 2);
  }

  void _startPress(double itemWidth) {
    _transitionTimer?.cancel();
    final center = _centerDxForIndex(widget.selectedIndex, itemWidth);
    setState(() {
      _interactionIndex = widget.selectedIndex;
      _interactionDx = center;
      _travelDirection = 0;
      _motion = 0;
      _lastDx = center;
      _lastMicros = DateTime.now().microsecondsSinceEpoch;
      _isInteracting = true;
      _isTransitioning = false;
    });
  }

  void _startOrUpdateDrag(double dx, double width) {
    final nextIndex = _indexFromLocalDx(dx, width);
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (nextIndex - previous).toDouble().sign;
    final nowMicros = DateTime.now().microsecondsSinceEpoch;
    final dtMicros = (nowMicros - _lastMicros).clamp(1, 200000);
    final speed = (dx - _lastDx).abs() / (dtMicros / 1000); // px/ms
    final targetMotion = (speed / 1.8).clamp(0.0, 1.0);

    setState(() {
      _interactionIndex = nextIndex;
      _interactionDx = dx.clamp(0.0, width);
      _travelDirection = direction;
      _motion = lerpDouble(_motion, targetMotion, 0.42) ?? targetMotion;
      _lastDx = dx;
      _lastMicros = nowMicros;
      _isInteracting = true;
    });
  }

  void _startTransitionIfNeeded(int nextIndex) {
    if (nextIndex == widget.selectedIndex) {
      return;
    }
    _transitionTimer?.cancel();
    setState(() => _isTransitioning = true);
    _transitionTimer = Timer(const Duration(milliseconds: 560), () {
      if (mounted) {
        setState(() => _isTransitioning = false);
      }
    });
  }

  void _triggerReleaseJelly() {
    _releaseTimer?.cancel();
    setState(() => _releasePop = true);
    _releaseTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _releasePop = false;
          _motion = 0;
        });
      }
    });
  }

  void _endInteraction({bool shouldCommit = true}) {
    final commitIndex = _interactionIndex ?? widget.selectedIndex;
    if (shouldCommit) {
      _startTransitionIfNeeded(commitIndex);
      if (commitIndex != widget.selectedIndex) {
        widget.onChanged(commitIndex);
      }
    }
    _triggerReleaseJelly();
    setState(() {
      _isInteracting = false;
      _interactionIndex = null;
      _interactionDx = null;
      _travelDirection = 0;
    });
  }

  void _commitTap(TapUpDetails details, double navWidth) {
    final index = _indexFromLocalDx(details.localPosition.dx, navWidth);
    _startTransitionIfNeeded(index);
    if (index != widget.selectedIndex) {
      widget.onChanged(index);
    }
    _triggerReleaseJelly();
    setState(() {
      _isInteracting = false;
      _interactionIndex = null;
      _interactionDx = null;
      _travelDirection = 0;
    });
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _releaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const innerSidePadding = 8.0;
    const barHeight = 74.0;
    final activeIndex = _interactionIndex ?? widget.selectedIndex;
    final transparent = _isInteracting || _isTransitioning;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: SizedBox(
        height: 96,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final navWidth = constraints.maxWidth - (innerSidePadding * 2);
            final itemWidth = navWidth / widget.tabs.length;
            final lensWidth = itemWidth * 0.96;

            final centerDx =
                _interactionDx ?? _centerDxForIndex(activeIndex, itemWidth);
            final lensLeft =
                innerSidePadding +
                (centerDx - (lensWidth / 2)).clamp(0.0, navWidth - lensWidth);

            final lensHeight = transparent ? 72.0 : 58.0;
            final lensBottom = ((barHeight - lensHeight) / 2);
            final stretchX = transparent
                ? (1.0 + (0.18 * _motion) + (_releasePop ? 0.10 : 0.0))
                : 1.0;
            final squashY = transparent
                ? (1.0 - (0.14 * _motion) - (_releasePop ? 0.08 : 0.0))
                : 1.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: const Color(0x55FFFFFF),
                        width: 1.2,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x4DF3FAFF), Color(0x33A7B7FF)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: innerSidePadding,
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < widget.tabs.length; i++)
                            Expanded(
                              child: _NavItemButton(
                                tab: widget.tabs[i],
                                selected: i == widget.selectedIndex,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _isInteracting
                      ? Duration.zero
                      : const Duration(milliseconds: 560),
                  curve: _isInteracting ? Curves.linear : Curves.elasticOut,
                  left: lensLeft,
                  bottom: lensBottom,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.diagonal3Values(stretchX, squashY, 1),
                    alignment: Alignment.center,
                    child: _NavLens(
                      width: lensWidth,
                      height: lensHeight,
                      isTransparent: transparent,
                      travelDirection: _travelDirection,
                    ),
                  ),
                ),
                Positioned(
                  left: innerSidePadding,
                  right: innerSidePadding,
                  bottom: 0,
                  height: barHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => _startPress(itemWidth),
                    onTapUp: (details) => _commitTap(details, navWidth),
                    onTapCancel: () => _endInteraction(shouldCommit: false),
                    onPanDown: (_) => _startPress(itemWidth),
                    onPanStart: (details) =>
                        _startOrUpdateDrag(details.localPosition.dx, navWidth),
                    onPanUpdate: (details) =>
                        _startOrUpdateDrag(details.localPosition.dx, navWidth),
                    onPanEnd: (_) => _endInteraction(),
                    onPanCancel: () => _endInteraction(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({required this.tab, required this.selected});

  final NavTab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final fgColor = selected
        ? const Color(0xFF243244)
        : const Color(0xFF6C7786);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.icon, color: fgColor, size: 21),
          const SizedBox(height: 4),
          SizedBox(
            height: 14,
            child: Center(
              child: Text(
                tab.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fgColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLens extends StatelessWidget {
  const _NavLens({
    required this.width,
    required this.height,
    required this.isTransparent,
    required this.travelDirection,
  });

  final double width;
  final double height;
  final bool isTransparent;
  final double travelDirection;

  @override
  Widget build(BuildContext context) {
    if (!isTransparent) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F7FB), Color(0xFFE8EDF4)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              spreadRadius: -8,
              offset: Offset(0, 5),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: CustomPaint(
          painter: _IridescentRingPainter(turn: travelDirection),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x2EFFFFFF),
                ],
                stops: [0.0, 0.78, 1.0],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  spreadRadius: -8,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IridescentRingPainter extends CustomPainter {
  const _IridescentRingPainter({required this.turn});

  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1.1),
      const Radius.circular(34),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = SweepGradient(
        transform: GradientRotation(turn * 0.35),
        colors: const [
          Color(0x66FF9DD4),
          Color(0x66A5CBFF),
          Color(0x66C6FFC7),
          Color(0x66FFD7A2),
          Color(0x66FF9DD4),
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _IridescentRingPainter oldDelegate) {
    return oldDelegate.turn != turn;
  }
}
