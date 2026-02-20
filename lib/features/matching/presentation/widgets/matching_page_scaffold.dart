import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_app_bar.dart';
import 'package:flutter/material.dart';

/// 매칭 플로우 공통 페이지 레이아웃: ClubalBackground + SafeArea + 앱바 + 본문.
/// 자동매치, 조각 만들기, 조각 상세 등에서 동일한 뼈대 사용.
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
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MatchingAppBar(
                    title: title,
                    onBack: onBack,
                    trailing: appBarTrailing,
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
