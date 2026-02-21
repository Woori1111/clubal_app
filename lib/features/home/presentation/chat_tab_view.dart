import 'package:clubal_app/features/chat/presentation/chat_list_page.dart';
import 'package:flutter/material.dart';

/// 채팅 탭 래퍼. 동일 탭 재탭 시 스크롤 맨 위로 이동을 위해 scrollController 전달.
class ChatTabView extends StatelessWidget {
  const ChatTabView({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ChatListPage(scrollController: scrollController);
  }
}

