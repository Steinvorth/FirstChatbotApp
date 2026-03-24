import 'package:first_chat_app/API/APIClient.dart';

/// Service layer for chat-related API operations.
/// Uses APIClient for all HTTP calls — keeps networking out of the UI.
class ChatService {
  ChatService._();

  /// Sends a message and streams SSE events back.
  /// Yields SSEEvent objects: conversation_id, token, done.
  static Stream<SSEEvent> SendMessageStream({
    required String message,
    String? conversationId,
  }) {
    final body = <String, dynamic>{'message': message};
    if (conversationId != null) {
      body['conversation_id'] = conversationId;
    }
    return APIClient.PostStream('/chat/send', body: body);
  }

  /// Fetches the message history for a specific conversation.
  static Future<Map<String, dynamic>> GetHistory({
    required String conversationId,
  }) async {
    return await APIClient.Get('/chat/history/$conversationId');
  }

  /// Fetches the list of all conversations.
  static Future<Map<String, dynamic>> GetConversations() async {
    return await APIClient.Get('/chat/conversations');
  }

  /// Deletes a conversation by its ID.
  static Future<Map<String, dynamic>> DeleteConversation({
    required String conversationId,
  }) async {
    return await APIClient.Delete('/chat/history/$conversationId');
  }
}
