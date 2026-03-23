import 'package:flutter/material.dart';
import 'package:first_chat_app/Theme/index.dart';
import 'package:first_chat_app/Services/index.dart';
import 'package:first_chat_app/Widgets/index.dart';

/// Main chat page with responsive layout.
///
/// Desktop (>= 768px): sidebar pinned on the left, collapsible with animation.
/// Mobile (< 768px): sidebar accessed via Drawer (hamburger menu).
///
/// The sidebar and chat content both have independent scroll views.
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
  final List<ConversationData> _conversations = [];

  // ─── Responsive breakpoint ────────────────────────────
  static const double _desktopBreakpoint = 768;
  static const double _sidebarWidth = 280;

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
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
    // Close drawer on mobile after action
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _HandleSelectConversation(String conversationId) {
    setState(() {
      _selectedConversationId = conversationId;
    });
    _LoadHistory(conversationId);
    // Close drawer on mobile after selection
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _HandleDeleteConversation(String conversationId) {
    ChatService.DeleteConversation(conversationId: conversationId);
    setState(() {
      _conversations.removeWhere((c) => c.id == conversationId);
      if (_selectedConversationId == conversationId) {
        _selectedConversationId = null;
        _messages = [];
      }
    });
  }

  Future<void> _LoadHistory(String conversationId) async {
    final result = await ChatService.GetHistory(conversationId: conversationId);
    // TODO: Parse the response and populate _messages
    // For now this is a stub — you'll wire this when the API is ready.
    debugPrint('History response: $result');
  }

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

    // Call the API
    final result = await ChatService.SendMessage(
      message: text,
      conversationId: _selectedConversationId,
    );

    setState(() {
      _isLoading = false;

      // Extract the AI response — adjust the key when your API is ready
      final aiMessage =
          result['response'] ??
          result['message'] ??
          result['detail'] ??
          'No response from API';

      _messages.add(
        ChatMessageData(message: aiMessage.toString(), isUser: false),
      );
    });
    _ScrollToBottom();
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
        // ─── Chat messages (scrollable) ──────────────
        Expanded(
          child: ChatMessageList(
            messages: _messages,
            scrollController: _chatScrollController,
          ),
        ),

        // ─── Input bar (pinned to bottom) ────────────
        ChatInputBar(
          controller: _messageController,
          onSend: _HandleSendMessage,
          isLoading: _isLoading,
        ),
      ],
    );
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
          : null, // On mobile, Scaffold auto-adds the drawer hamburger
      title: Text(
        _selectedConversationId ?? 'New Chat',
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
            // ─── Collapsible sidebar with animation ────
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

            // ─── Chat area fills remaining space ───────
            Expanded(child: _BuildChatArea()),
          ],
        ),
      );
    }

    // ─── Mobile layout: sidebar as Drawer ───────────────
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
