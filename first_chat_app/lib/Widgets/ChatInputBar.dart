import 'package:flutter/material.dart';
import 'package:first_chat_app/UI/index.dart';
import 'package:first_chat_app/Theme/index.dart';

/// Composite widget: text input + send button, pinned to bottom of chat.
/// Handles layout and passes events up to the parent.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ChatInput(
                controller: controller,
                onSubmit: onSend,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 8),
            SendButton(onPressed: onSend, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
