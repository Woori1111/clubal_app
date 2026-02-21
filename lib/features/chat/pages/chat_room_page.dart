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
import 'package:clubal_app/features/chat/widgets/report_sheet.dart';
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
    this.initialIsMuted,
    this.onMuteChanged,
    this.onLeaveConfirm,
  });

  final String chatId;
  final ChatRoom? room;
  final String? otherUserName;
  final String? otherUserImageUrl;
  final ChatRepository? repository;
  final bool? initialIsMuted;
  final void Function(bool isMuted)? onMuteChanged;
  final VoidCallback? onLeaveConfirm;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  List<Message> _messages = [];
  bool _isBlocked = false;
  bool _showBlockedSystemMessage = false;

  ChatRepository get _repo => widget.repository ?? getChatRepository();

  String get _displayName => widget.room?.displayName ?? widget.otherUserName ?? '';

  bool get _isMuted => _localMuted ?? widget.room?.isMuted ?? false;
  bool? _localMuted;

  int get _participantCount => widget.room?.participantCount ?? 1;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.room?.isBlocked ?? false;
    _localMuted = widget.initialIsMuted ?? widget.room?.isMuted ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _repo.markAsRead(widget.chatId);
    });
  }

  void _onReport() {
    showReportSheet(
      context,
      targetName: _displayName,
      onSubmit: () {
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('신고 완료'),
            content: const Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('신고 접수가 완료되었습니다.')),
                  );
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBlock() {
    setState(() {
      _isBlocked = true;
      _showBlockedSystemMessage = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('차단되었습니다.')),
    );
  }

  void _onUnblock() {
    setState(() {
      _isBlocked = false;
      _showBlockedSystemMessage = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('차단이 해제되었습니다.')),
    );
  }

  void _onLeaveTap() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('채팅방 나가기'),
        content: const Text('정말 이 채팅방을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        widget.onLeaveConfirm?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방을 나갔습니다.')),
        );
      }
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
        toolbarHeight: 64,
        title: Padding(
          padding: const EdgeInsets.only(right: 8, top: 4),
          child: Row(
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
                size: 40,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: _onHeaderTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _displayName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.room?.isGroup ?? false) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '👥 $_participantCount',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ],
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
              Transform.translate(
                offset: const Offset(0, 2),
                child: IconButton(
                  icon: const Icon(Icons.search_rounded, size: 26),
                  iconSize: 26,
                  onPressed: () {
                    showChatSearchSheet(
                      context,
                      messages: _messages,
                      roomName: _displayName,
                    );
                  },
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 2),
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 26),
                  iconSize: 26,
                  onPressed: () {
                    showChatRoomOptionsSheet(
                      context,
                      roomName: _displayName,
                      isMuted: _isMuted,
                      isBlocked: _isBlocked,
                      onReport: _onReport,
                      onBlock: _onBlock,
                      onUnblock: _isBlocked ? _onUnblock : null,
                      onToggleMute: () {
                        final next = !_isMuted;
                        setState(() => _localMuted = next);
                        widget.onMuteChanged?.call(next);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(next ? '알림이 꺼졌습니다.' : '알림이 켜졌습니다.')),
                        );
                      },
                      onLeave: _onLeaveTap,
                    );
                  },
                ),
              ),
            ],
          ),
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

                final items = _buildMessageItems(_messages, isGroup, _showBlockedSystemMessage);

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
          if (_isBlocked)
            _BlockedInputBar(onUnblock: _onUnblock)
          else
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

  List<Widget> _buildMessageItems(List<Message> messages, bool isGroup, bool showBlockedMsg) {
    DateTime? lastDate;
    final result = <Widget>[];

    if (showBlockedMsg) {
      result.add(SystemMessageBubble(text: '이 사용자를 차단했습니다'));
    }

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

class _BlockedInputBar extends StatelessWidget {
  const _BlockedInputBar({required this.onUnblock});

  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Icons.block_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '이 사용자를 차단했습니다. 메시지를 보낼 수 없습니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
              ),
            ),
            TextButton(
              onPressed: onUnblock,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('차단 해제'),
            ),
          ],
        ),
      ),
    );
  }
}
