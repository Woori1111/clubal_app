import 'package:clubal_app/features/menu/pages/menu_activity_hub_page.dart';
import 'package:flutter/material.dart';

/// 메뉴 탭. 내 활동 허브(My Activity Hub) 구조.
/// 설정은 상단 톱니바퀴 아이콘으로 이동됨.
class MenuTabView extends StatelessWidget {
  const MenuTabView({
    super.key,
    this.scrollController,
    this.onSwitchToMatching,
  });

  final ScrollController? scrollController;
  final VoidCallback? onSwitchToMatching;

  @override
  Widget build(BuildContext context) {
    return MenuActivityHubPage(
      scrollController: scrollController,
      onSwitchToMatching: onSwitchToMatching,
    );
  }
}
