import 'package:flutter/material.dart';
import 'package:first_chat_app/Theme/index.dart';
import 'package:first_chat_app/UI/TypingIndicator.dart';

/// A single chat message bubble. Aligns right for user, left for AI.
/// When the message is empty and isUser is false, shows a typing indicator
/// (3 bouncing dots) while waiting for the first streamed token.
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  bool get _isWaitingForStream => !isUser && message.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? AppColors.userBubble : AppColors.aiBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.surfaceBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isWaitingForStream)
              const TypingIndicator()
            else
              Text(
                message,
                style: AppTypography.body.copyWith(
                  color: isUser
                      ? AppColors.userBubbleText
                      : AppColors.aiBubbleText,
                ),
              ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                timestamp!,
                style: AppTypography.caption.copyWith(
                  color: isUser
                      ? AppColors.userBubbleText.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
