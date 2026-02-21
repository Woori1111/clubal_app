import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/widgets/user_avatar.dart';
import 'package:clubal_app/features/chat/models/chat_room.dart';
import 'package:flutter/material.dart';

class StackedAvatars extends StatelessWidget {
  const StackedAvatars({
    super.key,
    required this.room,
    this.size = 48,
  });

  final ChatRoom room;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    if (room.isGroup && room.participants.isNotEmpty) {
      final display = room.participants.take(3).toList();
      return SizedBox(
        width: size + (display.length - 1) * radius * 0.6,
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < display.length; i++)
              Positioned(
                left: i * radius * 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: UserAvatar(
                    displayName: display[i].name,
                    imageUrl: display[i].imageUrl,
                    radius: radius - 2,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return UserAvatar(
      displayName: room.displayName,
      imageUrl: room.otherUserImageUrl ?? room.groupImage,
      radius: radius,
    );
  }
}
