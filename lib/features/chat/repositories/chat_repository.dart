import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/models/message.dart';

abstract class ChatRepository {
  Stream<List<ChatRoom>> getChatRooms();
  Stream<List<Message>> getMessages(String chatId);
  Future<void> markAsRead(String chatId);
  Future<void> sendTextMessage(String chatId, String text);
  Future<void> sendImageMessage(String chatId, Object imageFile);

  /// 자동매치 완료 시 6인 그룹 채팅방 생성
  Future<ChatRoom> createGroupRoom({
    required String pieceRoomId,
    required List<String> participantIds,
    required String roomName,
    String? locationTag,
    DateTime? meetingDate,
  });
}
