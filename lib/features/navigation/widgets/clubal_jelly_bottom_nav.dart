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
  bool _isInteracting = false;
  double _travelDirection = 0;

  int _indexFromLocalDx(double dx, double width) {
    final clampedDx = dx.clamp(0.0, width - 0.001);
    final itemWidth = width / widget.tabs.length;
    final index = (clampedDx / itemWidth).floor();
    return index.clamp(0, widget.tabs.length - 1);
  }

  double _centerDxForIndex(int index, double itemWidth) {
    return (itemWidth * index) + (itemWidth / 2);
  }

  void _startInteraction(int index, double itemWidth) {
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (index - previous).toDouble().sign;
    setState(() {
      _interactionIndex = index;
      _interactionDx = _centerDxForIndex(index, itemWidth);
      _isInteracting = true;
      _travelDirection = direction;
    });
    widget.onChanged(index);
  }

  void _updateInteractionByDx(double dx, double width) {
    final index = _indexFromLocalDx(dx, width);
    if (_interactionIndex == index && _isInteracting) {
      return;
    }
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (index - previous).toDouble().sign;
    setState(() {
      _interactionIndex = index;
      _interactionDx = dx.clamp(0.0, width);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const sidePadding = 8.0;
    final activeIndex = _interactionIndex ?? widget.selectedIndex;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0x55FFFFFF), width: 1.2),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x4DF3FAFF), Color(0x33A7B7FF)],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final navWidth = constraints.maxWidth - (sidePadding * 2);
                final itemWidth = navWidth / widget.tabs.length;
                final lensWidth = itemWidth * 0.96;
                final restingLensLeft =
                    sidePadding +
                    (itemWidth * activeIndex) +
                    (itemWidth - lensWidth) / 2;
                final dragLensLeft =
                    sidePadding +
                    ((_interactionDx ??
                                _centerDxForIndex(activeIndex, itemWidth)) -
                            (lensWidth / 2))
                        .clamp(0.0, navWidth - lensWidth);
                final lensLeft = _isInteracting
                    ? dragLensLeft
                    : restingLensLeft;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isInteracting
                          ? Duration.zero
                          : const Duration(milliseconds: 520),
                      curve: _isInteracting ? Curves.linear : Curves.elasticOut,
                      left: lensLeft,
                      top: 6,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOutCubic,
                        scale: _isInteracting ? 1.08 : 1.0,
                        child: _NavLens(
                          width: lensWidth,
                          isInteracting: _isInteracting,
                          travelDirection: _travelDirection,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      left: sidePadding,
                      right: sidePadding,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (details) =>
                            _updateInteractionByDx(
                              details.localPosition.dx,
                              navWidth,
                            ),
                        onHorizontalDragUpdate: (details) =>
                            _updateInteractionByDx(
                              details.localPosition.dx,
                              navWidth,
                            ),
                        onHorizontalDragEnd: (_) => _endInteraction(),
                        onHorizontalDragCancel: _endInteraction,
                        child: Row(
                          children: [
                            for (int i = 0; i < widget.tabs.length; i++)
                              Expanded(
                                child: _NavItemButton(
                                  tab: widget.tabs[i],
                                  selected: i == widget.selectedIndex,
                                  onTapDown: () =>
                                      _startInteraction(i, itemWidth),
                                  onTap: () {
                                    widget.onChanged(i);
                                    _endInteraction();
                                  },
                                  onTapCancel: _endInteraction,
                                  onTapUp: _endInteraction,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.tab,
    required this.selected,
    required this.onTapDown,
    required this.onTap,
    required this.onTapUp,
    required this.onTapCancel,
  });

  final NavTab tab;
  final bool selected;
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(tab.icon, color: fgColor, size: 26),
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
        ),
      ),
    );
  }
}

class _NavLens extends StatelessWidget {
  const _NavLens({
    required this.width,
    required this.isInteracting,
    required this.travelDirection,
  });

  final double width;
  final bool isInteracting;
  final double travelDirection;

  @override
  Widget build(BuildContext context) {
    if (!isInteracting) {
      return Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9AE1FF), Color(0xFF69C6F6)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5522B8FF),
              blurRadius: 16,
              spreadRadius: -8,
              offset: Offset(0, 7),
            ),
          ],
        ),
      );
    }

    final leadingBoost = travelDirection < 0 ? 1.0 : 0.56;
    final trailingBoost = travelDirection > 0 ? 1.0 : 0.56;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x35FFFFFF), Color(0x10FFFFFF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 18,
                spreadRadius: -8,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 2,
                left: width * 0.18,
                right: width * 0.18,
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
                left: -8,
                top: 8,
                child: _LensEdgeGlow(size: 42, strength: leadingBoost),
              ),
              Positioned(
                right: -8,
                top: 8,
                child: _LensEdgeGlow(size: 42, strength: trailingBoost),
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
