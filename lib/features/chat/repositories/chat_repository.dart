import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/models/message.dart';

abstract class ChatRepository {
  Stream<List<ChatRoom>> getChatRooms();
  Stream<List<Message>> getMessages(String chatId);
  Future<void> markAsRead(String chatId);
  Future<void> sendTextMessage(String chatId, String text);
  Future<void> sendImageMessage(String chatId, Object imageFile);
}
