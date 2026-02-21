# 채팅 기능 연동 방법

채팅 목록을 탭에 표시하려면 `lib/features/home/presentation/chat_tab_view.dart`에서 아래처럼 수정하세요:

```dart
import 'package:clubal_app/features/chat/presentation/chat_list_page.dart';
import 'package:flutter/material.dart';

class ChatTabView extends StatelessWidget {
  const ChatTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatListPage();
  }
}
```

Firestore 인덱스: `chats` 컬렉션에서 `participantIds`(array-contains) + `lastMessageAt`(desc) 조합 쿼리 시
필요하면 Firebase Console에서 복합 인덱스를 생성하세요.
