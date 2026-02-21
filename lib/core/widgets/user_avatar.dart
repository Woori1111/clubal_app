import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 프로필 이미지 또는 이름 첫 글자 fallback을 표시하는 공통 아바타 위젯.
/// 채팅 목록, 채팅방 상단, 프로필 등에서 재사용.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.displayName,
    this.imageUrl,
    this.radius = 28,
  });

  final String displayName;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return CircleAvatar(
      radius: radius,
      backgroundColor: isDark
          ? AppColors.glassBorderDark
          : AppColors.captionText.withValues(alpha: 0.2),
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: TextStyle(
                color: onSurfaceVariant,
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}
