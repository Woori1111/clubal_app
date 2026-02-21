enum MessageType { text, image, system }

class Message {
  const Message({
    required this.id,
    required this.type,
    this.text,
    this.imageUrl,
    required this.createdAt,
    required this.isMe,
    this.senderId,
    this.senderName,
    this.content,
    this.isSystemMessage = false,
    this.isRead = false,
  });

  final String id;
  final MessageType type;
  final String? text;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isMe;

  final String? senderId;
  final String? senderName;
  final String? content;
  final bool isSystemMessage;
  final bool isRead;

  String get displayContent => content ?? text ?? '';
}
