import 'dart:math' as math;
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _fromT = 0.0;
  double _toT = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addListener(() => setState(() {}));

    _toT = _indexToT(widget.selectedIndex);
    _fromT = _toT;
  }

  @override
  void didUpdateWidget(covariant ClubalJellyBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _fromT = _currentT;
      _toT = _indexToT(widget.selectedIndex);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _indexToT(int index) {
    if (widget.tabs.length <= 1) {
      return 0.5;
    }
    return index / (widget.tabs.length - 1);
  }

  double get _currentT {
    if (!_controller.isAnimating) {
      return _toT;
    }
    final eased = Curves.easeOutCubic.transform(_controller.value);
    return lerpDouble(_fromT, _toT, eased) ?? _toT;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navHeight = 74.0;
    const sideInset = 8.0;
    const outerRadius = 34.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: SizedBox(
        height: navHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final navWidth = constraints.maxWidth - (sideInset * 2);
            final itemWidth = navWidth / widget.tabs.length;
            final blobWidth = itemWidth * 0.95;
            final blobHeight = 58.0;
            final blobLeft =
                sideInset + (navWidth * _currentT) - (blobWidth / 2);
            final pulse = math.sin(_controller.value * math.pi);
            final stretchX = 1 + (pulse * 0.18);
            final squashY = 1 - (pulse * 0.12);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(outerRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(outerRadius),
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
                    ),
                  ),
                ),
                Positioned(
                  left: blobLeft,
                  top: (navHeight - blobHeight) / 2,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(stretchX, squashY, 1),
                    child: _FloatingGlassBlob(
                      width: blobWidth,
                      height: blobHeight,
                    ),
                  ),
                ),
                Positioned(
                  left: sideInset,
                  right: sideInset,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.tabs.length; i++)
                        Expanded(
                          child: _NavItemButton(
                            tab: widget.tabs[i],
                            selected: i == widget.selectedIndex,
                            onTap: () => widget.onChanged(i),
                          ),
                        ),
                    ],
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

class _FloatingGlassBlob extends StatelessWidget {
  const _FloatingGlassBlob({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x99FFFFFF), Color(0x55FFFFFF)],
            ),
            border: Border.all(color: const Color(0x99FFFFFF), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A000000),
                blurRadius: 16,
                spreadRadius: -6,
                offset: Offset(0, 8),
              ),
            ],
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
    required this.onTap,
  });

  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fgColor = selected
        ? const Color(0xFF243244)
        : const Color(0xFF6C7786);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, color: fgColor, size: 21),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
