import 'dart:async';

import 'package:clubal_app/features/chat/dummy/dummy_chat_data.dart';
import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/models/message.dart';
import 'package:clubal_app/features/chat/repositories/chat_repository.dart';

class DummyChatRepository implements ChatRepository {
  DummyChatRepository();

  final List<ChatRoom> _rooms = createDummyRooms();
  final Map<String, List<Message>> _messagesByChatId = createDummyMessages();
  static const String _autoMatchChatPrefix = 'piece_';
  final StreamController<List<ChatRoom>> _roomsController =
      StreamController<List<ChatRoom>>.broadcast();
  final Map<String, StreamController<List<Message>>> _messagesControllers = {};

  void _updateRoom(ChatRoom updated) {
    final idx = _rooms.indexWhere((r) => r.id == updated.id);
    if (idx >= 0) {
      _rooms[idx] = updated;
      _roomsController.add(List.from(_rooms));
    }
  }

  @override
  Stream<List<ChatRoom>> getChatRooms() async* {
    yield List.from(_rooms);
    yield* _roomsController.stream;
  }

  @override
  Stream<List<Message>> getMessages(String chatId) async* {
    _messagesControllers[chatId] ??=
        StreamController<List<Message>>.broadcast();
    final list = _messagesByChatId[chatId] ?? [];
    yield List.from(list);
    yield* _messagesControllers[chatId]!.stream;
  }

  void _emitMessages(String chatId) {
    final list = _messagesByChatId[chatId] ?? [];
    _messagesControllers[chatId]?.add(List.from(list));
  }

  void _updateRoomLastMessage(String chatId, String lastMessage) {
    final idx = _rooms.indexWhere((r) => r.id == chatId);
    if (idx >= 0) {
      final r = _rooms[idx];
      _updateRoom(ChatRoom(
        id: r.id,
        otherUserId: r.otherUserId,
        otherUserName: r.otherUserName,
        otherUserImageUrl: r.otherUserImageUrl,
        lastMessage: lastMessage,
        lastMessageAt: DateTime.now(),
        unreadCount: r.unreadCount,
        name: r.name,
        participants: r.participants,
        isGroup: r.isGroup,
        groupImage: r.groupImage,
        isPinned: r.isPinned,
        locationTag: r.locationTag,
        meetingDate: r.meetingDate,
        isMuted: r.isMuted,
        isOnline: r.isOnline,
      ));
    }
  }

  @override
  Future<void> markAsRead(String chatId) async {
    final idx = _rooms.indexWhere((r) => r.id == chatId);
    if (idx >= 0 && _rooms[idx].unreadCount > 0) {
      final r = _rooms[idx];
      _updateRoom(ChatRoom(
        id: r.id,
        otherUserId: r.otherUserId,
        otherUserName: r.otherUserName,
        otherUserImageUrl: r.otherUserImageUrl,
        lastMessage: r.lastMessage,
        lastMessageAt: r.lastMessageAt,
        unreadCount: 0,
        name: r.name,
        participants: r.participants,
        isGroup: r.isGroup,
        groupImage: r.groupImage,
        isPinned: r.isPinned,
        locationTag: r.locationTag,
        meetingDate: r.meetingDate,
        isMuted: r.isMuted,
        isOnline: r.isOnline,
      ));
    }
  }

  @override
  Future<void> sendTextMessage(String chatId, String text) async {
    _messagesByChatId[chatId] ??= [];
    final msg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.text,
      text: text,
      createdAt: DateTime.now(),
      isMe: true,
    );
    _messagesByChatId[chatId]!.add(msg);
    _emitMessages(chatId);
    _updateRoomLastMessage(chatId, text);
  }

  @override
  Future<void> sendImageMessage(String chatId, Object imageFile) async {
    _messagesByChatId[chatId] ??= [];
    final msg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.image,
      imageUrl: 'https://picsum.photos/seed/${chatId}_${DateTime.now().millisecondsSinceEpoch}/400/300',
      createdAt: DateTime.now(),
      isMe: true,
    );
    _messagesByChatId[chatId]!.add(msg);
    _emitMessages(chatId);
    _updateRoomLastMessage(chatId, '[사진]');
  }

  @override
  Future<ChatRoom> createGroupRoom({
    required String pieceRoomId,
    required List<String> participantIds,
    required String roomName,
    String? locationTag,
    DateTime? meetingDate,
  }) async {
    final chatId = '$_autoMatchChatPrefix$pieceRoomId';
    if (_rooms.any((r) => r.id == chatId)) {
      return _rooms.firstWhere((r) => r.id == chatId);
    }
    final now = DateTime.now();
    final participants = participantIds
        .asMap()
        .entries
        .map((e) => ChatParticipant(
              userId: e.value,
              name: '참여자 ${e.key + 1}',
            ))
        .toList();
    final room = ChatRoom(
      id: chatId,
      otherUserId: participantIds.isNotEmpty ? participantIds.first : '',
      otherUserName: roomName,
      name: roomName,
      participants: participants,
      isGroup: true,
      lastMessage: '자동매치로 6인이 모였습니다.',
      lastMessageAt: now,
      locationTag: locationTag,
      meetingDate: meetingDate,
    );
    _rooms.insert(0, room);
    _messagesByChatId[chatId] = [
      Message(
        id: 'sys_${now.millisecondsSinceEpoch}',
        type: MessageType.system,
        content: '자동매치로 6인이 모였습니다. 채팅을 시작해보세요!',
        createdAt: now,
        isMe: false,
        isSystemMessage: true,
      ),
    ];
    _roomsController.add(List.from(_rooms));
    return room;
  }
}
