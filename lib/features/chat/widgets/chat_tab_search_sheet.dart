import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/utils/date_utils.dart' as app_date_utils;
import 'package:clubal_app/features/chat/chat_dependencies.dart';
import 'package:clubal_app/features/chat/dummy/dummy_chat_data.dart';
import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/models/message.dart';
import 'package:clubal_app/features/chat/pages/chat_room_page.dart';
import 'package:clubal_app/features/chat/widgets/stacked_avatars.dart';
import 'package:flutter/material.dart';

void showChatTabSearchSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ChatTabSearchSheet(),
  );
}

class _ChatTabSearchSheet extends StatefulWidget {
  const _ChatTabSearchSheet();

  @override
  State<_ChatTabSearchSheet> createState() => _ChatTabSearchSheetState();
}

class _ChatTabSearchSheetState extends State<_ChatTabSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  late final List<ChatRoom> _allRooms = createDummyRooms();
  late final Map<String, List<Message>> _allMessages = createDummyMessages();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _query = _controller.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<ChatRoom> get _matchedRooms {
    if (_query.isEmpty) return [];
    return _allRooms
        .where((r) =>
            r.displayName.toLowerCase().contains(_query) ||
            r.otherUserName.toLowerCase().contains(_query) ||
            (r.name?.toLowerCase().contains(_query) ?? false))
        .toList();
  }

  ChatRoom? _roomById(String id) {
    for (final r in _allRooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<_MessageWithRoom> get _matchedMessages {
    if (_query.isEmpty) return [];
    final result = <_MessageWithRoom>[];
    for (final entry in _allMessages.entries) {
      final room = _roomById(entry.key);
      final roomName = room?.displayName ?? '';
      for (final m in entry.value) {
        if (m.type != MessageType.text) continue;
        final content = m.displayContent.toLowerCase();
        final sender = (m.senderName ?? '').toLowerCase();
        if (content.contains(_query) || sender.contains(_query)) {
          result.add(_MessageWithRoom(message: m, roomId: entry.key, roomName: roomName));
        }
      }
    }
    result.sort((a, b) => b.message.createdAt.compareTo(a.message.createdAt));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '채팅방·메시지 검색',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          Expanded(
            child: _query.isEmpty
                ? _EmptyState(colorScheme: colorScheme)
                : _SearchResults(
                    rooms: _matchedRooms,
                    messages: _matchedMessages,
                    query: _query,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    onRoomTap: _onRoomTap,
                    onMessageTap: _onMessageTap,
                  ),
          ),
        ],
      ),
    );
  }

  void _onRoomTap(ChatRoom room) {
    final repo = getChatRepository();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomPage(
          chatId: room.id,
          room: room,
          repository: repo,
        ),
      ),
    );
  }

  void _onMessageTap(String roomId, String roomName) {
    final room = _roomById(roomId);
    if (room == null) return;
    final repo = getChatRepository();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomPage(
          chatId: roomId,
          room: room,
          repository: repo,
        ),
      ),
    );
  }
}

class _MessageWithRoom {
  _MessageWithRoom({
    required this.message,
    required this.roomId,
    required this.roomName,
  });
  final Message message;
  final String roomId;
  final String roomName;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '검색어를 입력하세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '채팅방 이름, 참여자, 메시지로 검색합니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.rooms,
    required this.messages,
    required this.query,
    required this.colorScheme,
    required this.isDark,
    required this.onRoomTap,
    required this.onMessageTap,
  });

  final List<ChatRoom> rooms;
  final List<_MessageWithRoom> messages;
  final String query;
  final ColorScheme colorScheme;
  final bool isDark;
  final void Function(ChatRoom) onRoomTap;
  final void Function(String roomId, String roomName) onMessageTap;

  @override
  Widget build(BuildContext context) {
    final hasRooms = rooms.isNotEmpty;
    final hasMessages = messages.isNotEmpty;

    if (!hasRooms && !hasMessages) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (hasRooms) ...[
          _SectionLabel(label: '채팅방', count: rooms.length),
          const SizedBox(height: 10),
          ...rooms.map((r) => _RoomCard(room: r, onTap: () => onRoomTap(r))),
          const SizedBox(height: 20),
        ],
        if (hasMessages) ...[
          _SectionLabel(label: '메시지', count: messages.length),
          const SizedBox(height: 10),
          ...messages.map((m) => _MessageCard(
                message: m.message,
                roomName: m.roomName,
                query: query,
                onTap: () => onMessageTap(m.roomId, m.roomName),
              )),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                StackedAvatars(room: room, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room.lastMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.roomName,
    required this.query,
    required this.onTap,
  });

  final Message message;
  final String roomName;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor = isDark ? AppColors.captionTextDark : AppColors.captionText;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: captionColor.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      roomName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      app_date_utils.formatRelativeTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: captionColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message.displayContent,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.senderName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message.senderName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: captionColor,
                          fontSize: 11,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
