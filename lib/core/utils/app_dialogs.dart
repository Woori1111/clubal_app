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
