import 'package:flutter/material.dart';
import 'package:first_chat_app/UI/index.dart';
import 'package:first_chat_app/Theme/index.dart';

/// A data class representing a single chat message.
class ChatMessageData {
  final String message;
  final bool isUser;
  final String? timestamp;

  const ChatMessageData({
    required this.message,
    required this.isUser,
    this.timestamp,
  });
}

/// Scrollable list of chat messages.
/// Combines ChatBubble UI elements into a functional scrollable view.
class ChatMessageList extends StatelessWidget {
  final List<ChatMessageData> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  Widget _BuildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: AppTypography.subheading.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin chatting with the AI.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return _BuildEmptyState();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return ChatBubble(
          message: msg.message,
          isUser: msg.isUser,
          timestamp: msg.timestamp,
        );
      },
    );
  }
}
