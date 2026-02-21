import 'package:clubal_app/core/utils/date_utils.dart' as app_date_utils;
import 'package:clubal_app/features/chat/chat_dependencies.dart';
import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/pages/chat_room_page.dart';
import 'package:clubal_app/features/chat/repositories/chat_repository.dart';
import 'package:clubal_app/features/chat/widgets/chat_list_item.dart';
import 'package:clubal_app/features/chat/widgets/segment_tab.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
    this.repository,
    this.scrollController,
  });

  final ChatRepository? repository;
  final ScrollController? scrollController;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int _segmentIndex = 0;

  ChatRepository get _repo => widget.repository ?? getChatRepository();

  List<ChatRoom> _filterRooms(List<ChatRoom> rooms) {
    final filtered = rooms.where((r) {
      if (_segmentIndex == 0) return r.isGroup;
      return !r.isGroup;
    }).toList();
    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatRoom>>(
      stream: _repo.getChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '채팅 목록을 불러올 수 없습니다.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rooms = snapshot.data ?? [];
        final filtered = _filterRooms(rooms);

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _segmentIndex == 0
                        ? '모임 채팅이 없습니다'
                        : '1:1 채팅이 없습니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SegmentTab(
                  labels: const ['모임 채팅', '1:1 채팅'],
                  selectedIndex: _segmentIndex,
                  onChanged: (i) => setState(() => _segmentIndex = i),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final room = filtered[index];
                  return ChatListItem(
                    room: room,
                    formatTime: app_date_utils.formatRelativeTime,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatRoomPage(
                            chatId: room.id,
                            room: room,
                            repository: _repo,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
