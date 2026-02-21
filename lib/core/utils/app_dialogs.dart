import 'package:flutter/material.dart';

/// 스낵바 대신 사용하는 메시지 다이얼로그.
/// 프로젝트 전역에서 알림/오류 메시지는 이 함수만 사용한다.
Future<void> showMessageDialog(
  BuildContext context, {
  required String message,
  String? title,
  bool isError = false,
}) {
  final effectiveTitle = title ?? (isError ? '오류' : '알림');
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        effectiveTitle,
        style: TextStyle(
          color: isError ? Colors.redAccent : null,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

/// 게시글/댓글 옵션 더보기 다이얼로그
/// [isAuthor] 본인 작성글 여부
/// [isComment] 댓글 여부 (기본값 false, 게시글용)
/// [showHideUserOption] 이 사용자의 글 숨김 버튼 표시 여부 (커뮤니티 목록에서는 false)
Future<String?> showMoreOptionsDialog(
  BuildContext context, {
  required bool isAuthor,
  bool isComment = false,
  bool showHideUserOption = true,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final onSurface = theme.colorScheme.onSurface;
      
      final String hideTarget = isComment ? '댓글' : '게시물';
      final String targetText = isComment ? '댓글' : '글';

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(Icons.visibility_off_rounded, color: onSurface),
              title: Text('$hideTarget 숨기기'),
              onTap: () => Navigator.of(ctx).pop('hide'),
            ),
            ListTile(
              leading: const Icon(Icons.report_rounded, color: Colors.redAccent),
              title: const Text('신고', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.of(ctx).pop('report'),
            ),
            if (showHideUserOption)
              ListTile(
                leading: Icon(Icons.person_off_rounded, color: onSurface),
                title: Text('이 사용자의 $targetText 숨기기'),
                onTap: () => Navigator.of(ctx).pop('hide_user'),
              ),
            if (isAuthor) ...[
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: onSurface),
                title: Text('$targetText 수정하기'),
                onTap: () => Navigator.of(ctx).pop('edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                title: Text('$targetText 삭제', style: const TextStyle(color: Colors.redAccent)),
                onTap: () => Navigator.of(ctx).pop('delete'),
              ),
            ],
          ],
        ),
      );
    },
  );
}
