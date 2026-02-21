import 'package:clubal_app/core/widgets/clubal_app_bar.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:flutter/material.dart';

/// 앱 전역 공통 페이지 레이아웃: ClubalBackground + SafeArea + 앱바 + 본문 (매칭 화면 기준).
class ClubalPageScaffold extends StatelessWidget {
  const ClubalPageScaffold({
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
      body: Builder(
        builder: (context) => wrapFullBody(
          context,
          Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(child: ClubalBackground()),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClubalAppBar(
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
        ),
      ),
    );
  }
}
