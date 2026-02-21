import 'package:clubal_app/core/widgets/clubal_page_scaffold.dart';
import 'package:flutter/material.dart';

/// 매칭 플로우 공통 페이지 레이아웃. core의 ClubalPageScaffold와 동일 구조 사용.
class MatchingPageScaffold extends StatelessWidget {
  const MatchingPageScaffold({
    super.key,
    required this.title,
    this.onBack,
    this.appBarTrailing,
    required this.body,
    this.bottomPadding = 18,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? appBarTrailing;
  final Widget body;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ClubalPageScaffold(
      title: title,
      onBack: onBack,
      appBarTrailing: appBarTrailing,
      body: body,
      bottomPadding: bottomPadding,
    );
  }
}
