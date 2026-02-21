import 'package:clubal_app/features/chat/chat_dependencies.dart';
import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/models/message.dart';
import 'package:clubal_app/features/chat/pages/chat_calendar_page.dart';
import 'package:clubal_app/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:clubal_app/features/chat/repositories/chat_repository.dart';
import 'package:clubal_app/features/chat/widgets/chat_participants_sheet.dart';
import 'package:clubal_app/features/chat/widgets/chat_profile_card_sheet.dart';
import 'package:clubal_app/features/chat/widgets/chat_room_options_sheet.dart';
import 'package:clubal_app/features/chat/widgets/chat_search_sheet.dart';
import 'package:clubal_app/features/chat/widgets/date_separator.dart';
import 'package:clubal_app/features/chat/widgets/message_bubble.dart';
import 'package:clubal_app/features/chat/widgets/stacked_avatars.dart';
import 'package:clubal_app/features/chat/widgets/system_message_bubble.dart';
import 'package:clubal_app/features/chat/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.chatId,
    this.room,
    this.otherUserName,
    this.otherUserImageUrl,
    this.repository,
  });

  final String chatId;
  final ChatRoom? room;
  final String? otherUserName;
  final String? otherUserImageUrl;
  final ChatRepository? repository;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  List<Message> _messages = [];

  ChatRepository get _repo => widget.repository ?? getChatRepository();

  String get _displayName => widget.room?.displayName ?? widget.otherUserName ?? '';

  bool get _isMuted => widget.room?.isMuted ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _repo.markAsRead(widget.chatId);
    });
  }

  void _onHeaderTap() {
    final room = widget.room;
    if (room == null) return;
    if (room.isGroup) {
      showChatParticipantsSheet(context, room: room);
    } else {
      final other = room.participants
          .where((p) => p.userId != 'me' && p.userId == room.otherUserId)
          .firstOrNull;
      showChatProfileCardSheet(
        context,
        participant: other ??
            ChatParticipant(
              userId: room.otherUserId,
              name: room.otherUserName,
              imageUrl: room.otherUserImageUrl,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = widget.room?.isGroup ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            StackedAvatars(
              room: widget.room ??
                  ChatRoom(
                    id: widget.chatId,
                    otherUserId: '',
                    otherUserName: _displayName,
                    otherUserImageUrl: widget.otherUserImageUrl,
                    lastMessage: '',
                    lastMessageAt: DateTime.now(),
                  ),
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _onHeaderTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                showChatSearchSheet(
                  context,
                  messages: _messages,
                  roomName: _displayName,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                showChatRoomOptionsSheet(
                  context,
                  roomName: _displayName,
                  isMuted: _isMuted,
                  onReport: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('신고 접수가 완료되었습니다.')),
                    );
                  },
                  onBlock: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('차단되었습니다.')),
                    );
                  },
                  onToggleMute: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isMuted ? '알림이 켜졌습니다.' : '알림이 꺼졌습니다.')),
                    );
                  },
                  onLeave: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('채팅방을 나갔습니다.')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _repo.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '메시지를 불러올 수 없습니다.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                _messages = snapshot.data ?? [];

                if (_messages.isEmpty) {
                  return Center(
                    child: Text(
                      '대화를 시작해보세요',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  );
                }

                final items = _buildMessageItems(_messages, isGroup);

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return TypingIndicator(userName: '강남불나방');
                    }
                    return items[index - 1];
                  },
                );
              },
            ),
          ),
          ChatInputField(
            onSendText: (text) => _repo.sendTextMessage(widget.chatId, text),
            onSendImage: (file) => _repo.sendImageMessage(widget.chatId, file),
            onOpenCalendar: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatCalendarPage(
                    chatId: widget.chatId,
                    roomName: _displayName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMessageItems(List<Message> messages, bool isGroup) {
    DateTime? lastDate;
    final result = <Widget>[];

    for (final msg in messages.reversed) {
      final msgDate = DateTime(msg.createdAt.year, msg.createdAt.month, msg.createdAt.day);
      if (lastDate == null || lastDate != msgDate) {
        lastDate = msgDate;
        result.add(DateSeparator(date: msg.createdAt));
      }

      if (msg.type == MessageType.system || msg.isSystemMessage) {
        result.add(SystemMessageBubble(text: msg.displayContent));
      } else {
        result.add(MessageBubble(
          message: msg,
          showSenderName: isGroup && !msg.isMe,
        ));
      }
    }

    return result;
  }
}
