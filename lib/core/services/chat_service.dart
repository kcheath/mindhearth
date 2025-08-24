import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_bubble.dart';
import 'package:mindhearth/core/models/api_response.dart';
import 'package:mindhearth/app/providers/providers.dart';

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  // Current session ID for the active chat
  String? _currentSessionId;

  String? get currentSessionId => _currentSessionId;

  // Create a new chat session
  Future<String?> createChatSession({String? name}) async {
    try {
      final response = await _apiService.createSession(
        name: name ?? 'Chat Session',
        sessionType: 'conversation',
        purpose: 'AI-assisted therapy conversation',
      );

      return response.when(
        success: (data, message) {
          _currentSessionId = data['id'] as String?;
          return _currentSessionId;
        },
        error: (message, statusCode, errors) {
          print('Failed to create session: $message');
          return null;
        },
      );
    } catch (e) {
      print('Error creating session: $e');
      return null;
    }
  }

  // Load existing chat history
  Future<List<ChatMessage>> loadChatHistory({String? sessionId}) async {
    try {
      final targetSessionId = sessionId ?? _currentSessionId;
      if (targetSessionId == null) {
        return [];
      }

      final response = await _apiService.getCommunications(
        sessionId: targetSessionId,
        itemType: 'message',
        limit: 100,
      );

      return response.when(
        success: (data, message) {
          final communications = data['communications'] as List<dynamic>? ?? [];
          return communications.map((comm) {
            final commData = comm as Map<String, dynamic>;
            return ChatMessage(
              id: commData['id'] as String,
              message: commData['original_content'] as String? ?? '',
              isUser: commData['role'] == 'user',
              timestamp: DateTime.parse(commData['created_at'] as String),
              sessionId: commData['session_id'] as String?,
            );
          }).toList();
        },
        error: (message, statusCode, errors) {
          print('Failed to load chat history: $message');
          return [];
        },
      );
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  // Send a user message
  Future<ChatMessage?> sendUserMessage(String message) async {
    try {
      // Ensure we have a session
      if (_currentSessionId == null) {
        await createChatSession();
        if (_currentSessionId == null) {
          return null;
        }
      }

      // Send user message
      final userResponse = await _apiService.createCommunication(
        sessionId: _currentSessionId!,
        itemType: 'message',
        role: 'user',
        originalContent: message,
        consent: true,
      );

      return userResponse.when(
        success: (data, responseMessage) {
          return ChatMessage(
            id: data['id'] as String,
            message: message, // Use the original user message, not the API response message
            isUser: true,
            timestamp: DateTime.parse(data['created_at'] as String),
            sessionId: _currentSessionId,
          );
        },
        error: (errorMessage, statusCode, errors) {
          print('Failed to send user message: $errorMessage');
          return null;
        },
      );
    } catch (e) {
      print('Error sending user message: $e');
      return null;
    }
  }

  // Get AI response (this would integrate with the actual AI service)
  Future<ChatMessage?> getAIResponse(String userMessage) async {
    try {
      // For now, we'll create a placeholder AI response
      // In a real implementation, this would call the AI service
      final aiResponse = await _apiService.createCommunication(
        sessionId: _currentSessionId!,
        itemType: 'message',
        role: 'assistant',
        originalContent: _generateAIResponse(userMessage),
        consent: true,
      );

      return aiResponse.when(
        success: (data, message) {
          return ChatMessage(
            id: data['id'] as String,
            message: data['original_content'] as String? ?? '',
            isUser: false,
            timestamp: DateTime.parse(data['created_at'] as String),
            sessionId: _currentSessionId,
        );
        },
        error: (errorMessage, statusCode, errors) {
          print('Failed to get AI response: $errorMessage');
          return null;
        },
      );
    } catch (e) {
      print('Error getting AI response: $e');
      return null;
    }
  }

  // Temporary AI response generation (replace with real AI integration)
  String _generateAIResponse(String userMessage) {
    final responses = [
      "I hear you, and I want you to know that your feelings are valid. Can you tell me more about what's coming up for you right now?",
      "Thank you for sharing that with me. It sounds like you're going through something really challenging. How are you feeling about it?",
      "I appreciate you opening up to me. What you're experiencing is a normal response to difficult circumstances. Would you like to explore some coping strategies together?",
      "I can sense that this is really important to you. Let's take a moment to breathe together. What would be most helpful for you right now?",
      "Your courage in sharing this is remarkable. Healing is a journey, and you don't have to walk it alone. What kind of support would feel most helpful to you?",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  // Clear current session
  void clearSession() {
    _currentSessionId = null;
  }
}

// Provider for ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ChatService(apiService);
});
