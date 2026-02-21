import 'package:clubal_app/features/chat/pages/chat_room_page.dart' as pages;

/// 2026 트렌드 스타일 채팅방 (날짜 구분선, 시스템 메시지, 읽음, 입력 중 표시)
class ChatRoomPage extends pages.ChatRoomPage {
  const ChatRoomPage({
    super.key,
    required super.chatId,
    super.room,
    super.otherUserName,
    super.otherUserImageUrl,
    super.repository,
  });
}
