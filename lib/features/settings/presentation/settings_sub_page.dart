import 'package:clubal_app/core/widgets/clubal_scaffold.dart';
import 'package:flutter/material.dart';

/// 설정 하위 화면 공통 (결제/정산, 고객지원, 약관 및 정보, 계정 관리 등)
class SettingsSubPage extends StatelessWidget {
  const SettingsSubPage({
    super.key,
    required this.title,
    this.child,
  });

  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClubalScaffold(
      title: title,
      body: child ?? const SizedBox.shrink(),
    );
  }
}
