import 'package:flutter/material.dart';

/// 앱 전역 공통 앱바: 뒤로가기 + 제목 + 선택적 trailing (매칭 화면 기준).
class ClubalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClubalAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: onSurface),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
