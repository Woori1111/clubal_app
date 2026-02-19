import 'package:flutter/material.dart';

class ChatTabView extends StatelessWidget {
  const ChatTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '채팅 준비 중',
        style: TextStyle(
          color: Color(0xFF8A9BAF),
          fontSize: 16,
        ),
      ),
    );
  }
}

