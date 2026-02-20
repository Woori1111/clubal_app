import 'package:flutter/material.dart';

class RelativeTimeWidget extends StatelessWidget {
  const RelativeTimeWidget({
    super.key,
    required this.dateTime,
    this.style,
  });

  final DateTime dateTime;
  final TextStyle? style;

  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      // 0초 전도 처리 가능하도록
      final seconds = difference.inSeconds < 0 ? 0 : difference.inSeconds;
      return '$seconds초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${time.year}.${time.month.toString().padLeft(2, '0')}.${time.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getRelativeTime(dateTime),
      style: style,
    );
  }
}
