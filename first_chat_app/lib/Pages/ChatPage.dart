import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:first_chat_app/Theme/index.dart';
import 'package:first_chat_app/API/APIClient.dart';
import 'package:first_chat_app/Services/index.dart';
import 'package:first_chat_app/Widgets/index.dart';

/// Main chat page with responsive layout.
///
/// Desktop (>= 768px): sidebar pinned on the left, collapsible with animation.
/// Mobile (< 768px): sidebar accessed via Drawer (hamburger menu).
///
/// Fully wired to the FastAPI backend:
/// - Loads conversations on startup
/// - Sends messages and tracks conversation_id
/// - Loads history when selecting a conversation
/// - Deletes conversations
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ─── Controllers ──────────────────────────────────────
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // ─── State ────────────────────────────────────────────
  bool _isSidebarOpen = true;
  bool _isLoading = false;
  String? _selectedConversationId;
  List<ChatMessageData> _messages = [];
  List<ConversationData> _conversations = [];

  // ─── Responsive breakpoint ────────────────────────────
  static const double _desktopBreakpoint = 768;
  static const double _sidebarWidth = 280;

  @override
  void initState() {
    super.initState();
    _LoadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  // ─── API: Load conversations list ─────────────────────

  Future<void> _LoadConversations() async {
    try {
      final result = await ChatService.GetConversations();
      final List<dynamic> rawConversations = result['conversations'] ?? [];

      setState(() {
        _conversations = rawConversations.map((c) {
          return ConversationData(
            id: c['id'] ?? '',
            title: c['title'] ?? 'Untitled',
            lastMessage: c['last_message'],
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
    }
  }

  // ─── API: Load history for a conversation ─────────────

  Future<void> _LoadHistory(String conversationId) async {
    try {
      final result = await ChatService.GetHistory(
        conversationId: conversationId,
      );
      final List<dynamic> rawMessages = result['messages'] ?? [];

      setState(() {
        _selectedConversationId = conversationId;
        _messages = rawMessages.map((m) {
          return ChatMessageData(
            message: m['content'] ?? '',
            isUser: m['role'] == 'user',
          );
        }).toList();
      });
      _ScrollToBottom();
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  // ─── API: Send a message (streaming) ───────────────────

  Future<void> _HandleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message immediately for responsiveness
    setState(() {
      _messages.add(ChatMessageData(message: text, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();
    _ScrollToBottom();

    // Add an empty AI bubble that we'll fill with streamed tokens
    final aiBubbleIndex = _messages.length;
    setState(() {
      _messages.add(const ChatMessageData(message: '', isUser: false));
    });

    try {
      final stream = ChatService.SendMessageStream(
        message: text,
        conversationId: _selectedConversationId,
      );

      await for (final SSEEvent event in stream) {
        switch (event.event) {
          case 'conversation_id':
            setState(() {
              _selectedConversationId = event.data;
            });
            break;

          case 'token':
            // Token data is JSON-encoded string (handles newlines/quotes)
            final token = jsonDecode(event.data) as String;
            setState(() {
              final current = _messages[aiBubbleIndex];
              _messages[aiBubbleIndex] = ChatMessageData(
                message: current.message + token,
                isUser: false,
              );
            });
            _ScrollToBottom();
            break;

          case 'done':
            setState(() => _isLoading = false);
            await _LoadConversations();
            break;
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages[aiBubbleIndex] = const ChatMessageData(
          message: 'Error: Could not reach the API. Is the server running?',
          isUser: false,
        );
      });
      debugPrint('Failed to send message: $e');
    }
  }

  // ─── Actions ──────────────────────────────────────────

  void _ToggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  void _HandleNewChat() {
    setState(() {
      _selectedConversationId = null;
      _messages = [];
    });
    _messageController.clear();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _HandleSelectConversation(String conversationId) {
    _LoadHistory(conversationId);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _HandleDeleteConversation(String conversationId) async {
    try {
      await ChatService.DeleteConversation(conversationId: conversationId);
    } catch (e) {
      debugPrint('Failed to delete conversation: $e');
    }

    setState(() {
      _conversations.removeWhere((c) => c.id == conversationId);
      if (_selectedConversationId == conversationId) {
        _selectedConversationId = null;
        _messages = [];
      }
    });
  }

  void _ScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ────────────────────────────────────────────

  bool _IsDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  Widget _BuildSidebar() {
    return ConversationSidebar(
      conversations: _conversations,
      selectedConversationId: _selectedConversationId,
      onSelectConversation: _HandleSelectConversation,
      onDeleteConversation: _HandleDeleteConversation,
      onNewChat: _HandleNewChat,
    );
  }

  Widget _BuildChatArea() {
    return Column(
      children: [
        Expanded(
          child: ChatMessageList(
            messages: _messages,
            scrollController: _chatScrollController,
          ),
        ),
        ChatInputBar(
          controller: _messageController,
          onSend: _HandleSendMessage,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  String _GetAppBarTitle() {
    if (_selectedConversationId == null) return 'New Chat';
    final match = _conversations.where((c) => c.id == _selectedConversationId);
    if (match.isNotEmpty) return match.first.title;
    return 'Chat';
  }

  PreferredSizeWidget _BuildAppBar(bool isDesktop) {
    return AppBar(
      leading: isDesktop
          ? IconButton(
              icon: Icon(
                _isSidebarOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
              ),
              onPressed: _ToggleSidebar,
              tooltip: _isSidebarOpen ? 'Close sidebar' : 'Open sidebar',
            )
          : null,
      title: Text(
        _GetAppBarTitle(),
        style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _IsDesktop(context);

    if (isDesktop) {
      return Scaffold(
        appBar: _BuildAppBar(true),
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _isSidebarOpen ? _sidebarWidth : 0,
              child: _isSidebarOpen
                  ? SizedBox(
                      width: _sidebarWidth,
                      child: Row(
                        children: [
                          Expanded(child: _BuildSidebar()),
                          const VerticalDivider(width: 1),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(child: _BuildChatArea()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: _BuildAppBar(false),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(child: _BuildSidebar()),
      ),
      body: _BuildChatArea(),
    );
  }
}
