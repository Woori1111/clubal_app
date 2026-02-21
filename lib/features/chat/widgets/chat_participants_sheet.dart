import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:clubal_app/features/chat/widgets/chat_profile_card_sheet.dart';
import 'package:flutter/material.dart';

void showChatParticipantsSheet(
  BuildContext context, {
  required ChatRoom room,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ChatParticipantsSheet(room: room),
  );
}

class _ChatParticipantsSheet extends StatelessWidget {
  const _ChatParticipantsSheet({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final participants = room.participants.where((p) => p.userId != 'me').toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '참여자 (${participants.length}명)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final p = participants[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: p.imageUrl != null ? NetworkImage(p.imageUrl!) : null,
                    child: p.imageUrl == null
                        ? Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                  title: Text(p.name),
                  subtitle: p.bio != null ? Text(p.bio!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).pop();
                    showChatProfileCardSheet(context, participant: p);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
