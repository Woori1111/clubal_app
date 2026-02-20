import 'package:flutter/material.dart';

class BouncingLikeButton extends StatefulWidget {
  const BouncingLikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    this.onTap,
    this.iconSize = 18.0,
    this.textSize = 12.0,
    this.defaultColor = Colors.black,
    this.coloredWhenLiked = true,
  });

  final bool isLiked;
  final int likeCount;
  final VoidCallback? onTap;
  final double iconSize;
  final double textSize;
  final Color defaultColor;
  /// false면 좋아요 상태에서도 defaultColor만 사용 (커뮤니티 등 색 없이 표시)
  final bool coloredWhenLiked;

  @override
  State<BouncingLikeButton> createState() => _BouncingLikeButtonState();
}

class _BouncingLikeButtonState extends State<BouncingLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant BouncingLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 좋아요 상태가 변경되었을 때 애니메이션 실행
    if (widget.isLiked != oldWidget.isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = (widget.coloredWhenLiked && widget.isLiked)
        ? Colors.redAccent
        : widget.defaultColor;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Icon(
              widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: widget.iconSize,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.likeCount}',
            style: TextStyle(
              color: color,
              fontSize: widget.textSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
