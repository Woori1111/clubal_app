import 'package:clubal_app/features/chat/repositories/chat_repository.dart';
import 'package:clubal_app/features/chat/repositories/dummy_chat_repository.dart';

ChatRepository getChatRepository() => DummyChatRepository();
