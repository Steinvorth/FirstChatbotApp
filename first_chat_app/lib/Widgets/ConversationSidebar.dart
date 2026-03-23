import 'package:flutter/material.dart';
import 'package:first_chat_app/UI/index.dart';
import 'package:first_chat_app/Theme/index.dart';

/// A data class representing a conversation entry in the sidebar.
class ConversationData {
  final String id;
  final String title;
  final String? lastMessage;

  const ConversationData({
    required this.id,
    required this.title,
    this.lastMessage,
  });
}

/// The sidebar widget showing conversation history.
/// Scrollable list of ConversationTiles + a "New Chat" button at the top.
class ConversationSidebar extends StatelessWidget {
  final List<ConversationData> conversations;
  final String? selectedConversationId;
  final ValueChanged<String> onSelectConversation;
  final ValueChanged<String>? onDeleteConversation;
  final VoidCallback onNewChat;

  const ConversationSidebar({
    super.key,
    required this.conversations,
    required this.selectedConversationId,
    required this.onSelectConversation,
    required this.onNewChat,
    this.onDeleteConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // ─── Header + New Chat ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onNewChat,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: AppTypography.button,
                ),
              ),
            ),
          ),

          const Divider(),

          // ─── Conversation List (scrollable) ────────────
          Expanded(
            child: conversations.isEmpty
                ? _BuildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final convo = conversations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: SidebarTile(
                          title: convo.title,
                          subtitle: convo.lastMessage,
                          isSelected: convo.id == selectedConversationId,
                          onTap: () => onSelectConversation(convo.id),
                          onDelete: onDeleteConversation != null
                              ? () => onDeleteConversation!(convo.id)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _BuildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No conversations yet',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
