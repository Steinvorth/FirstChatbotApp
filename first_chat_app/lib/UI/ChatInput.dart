import 'package:flutter/material.dart';
import 'package:first_chat_app/Theme/index.dart';

/// Reusable text input field for the chat.
/// Handles text input, submit on enter, and exposes a controller.
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String hintText;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.hintText = 'Type a message...',
    this.isLoading = false,
  });

  void _HandleSubmit(String value) {
    if (value.trim().isEmpty) return;
    onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: isLoading ? null : _HandleSubmit,
      enabled: !isLoading,
      maxLines: null,
      textInputAction: TextInputAction.send,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: isLoading ? 'Waiting for response...' : hintText,
      ),
    );
  }
}
