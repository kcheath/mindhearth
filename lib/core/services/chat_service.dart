import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_bubble.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/services/credit_validator.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';

class ChatService {
  final ApiService _apiService;
  static const String _sessionsKey = 'chat_sessions';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  ChatService(this._apiService);

  // Current session ID for the active chat
  String? _currentSessionId;

  // Create a new chat session
  Future<String?> createChatSession({String? name}) async {
    try {
      // Generate a better default name if none provided
      final sessionName = name ?? _generateSessionName();
      
      final response = await _apiService.createSession(
        name: sessionName,
        sessionType: 'conversation',
        purpose: 'AI-assisted therapy conversation',
      );

      return response.when(
        success: (data, message) {
          _currentSessionId = data['id'] as String?;
          
          // Create session object for local storage
          final session = {
            'id': _currentSessionId,
            'name': sessionName,
            'session_type': 'conversation',
            'purpose': 'AI-assisted therapy conversation',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          // Save to local storage
          _addSessionLocally(session);
          
          appLogger.info('New chat session created', {
            'sessionId': _currentSessionId,
            'sessionName': sessionName,
          });
          return _currentSessionId;
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to create session', {'message': message});
          return null;
        },
      );
    } catch (e) {
      appLogger.error('Error creating session', {'error': e.toString()});
      return null;
    }
  }

  // Generate a meaningful session name
  String _generateSessionName() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return 'Chat Session - $timeStr';
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
          final messages = communications.map((comm) {
            final commData = comm as Map<String, dynamic>;
            return ChatMessage(
              id: commData['id'] as String,
              message: commData['original_content'] as String? ?? '',
              isUser: commData['role'] == 'user',
              timestamp: DateTime.parse(commData['created_at'] as String),
              sessionId: commData['session_id'] as String?,
            );
          }).toList();
          
          // Sort messages by timestamp (oldest first)
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to load chat history', {'message': message});
          return [];
        },
      );
    } catch (e) {
      appLogger.error('Error loading chat history', {'error': e.toString()});
      return [];
    }
  }

  // Check if user has sufficient credits for chat operation
  Future<bool> checkChatCredits() async {
    try {
      // Get billing status to check credits
      final billingResponse = await _apiService.getBillingStatus();
      
      return billingResponse.when(
        success: (billingStatusData, message) {
          final billingStatus = BillingStatus.fromJson(billingStatusData);
          final canChat = CreditValidator.canPerformChatOperation(billingStatus);
          appLogger.info('Chat credits check', {
            'canChat': canChat,
            'currentBalance': billingStatus.currentBalance,
            'status': billingStatus.status,
          });
          return canChat;
        },
        error: (message, statusCode, errors) {
          appLogger.warning('Failed to check billing status, allowing chat', {
            'error': message,
          });
          return true; // Allow chat if billing check fails
        },
      );
    } catch (e) {
      appLogger.warning('Error checking chat credits, allowing chat', {
        'error': e.toString(),
      });
      return true; // Allow chat if check fails
    }
  }

  // Send a user message and get AI response in one call
  Future<List<ChatMessage>?> sendMessageAndGetResponse(String message) async {
    try {
      // Check credits before sending message
      final hasCredits = await checkChatCredits();
      if (!hasCredits) {
        appLogger.warning('Insufficient credits for chat operation');
        return [
          ChatMessage(
            id: 'insufficient_credits_${DateTime.now().millisecondsSinceEpoch}',
            message: 'You don\'t have enough credits to send a chat message. This is completely normal - healing takes time and resources. You can purchase more credits or wait for your monthly grant.',
            isUser: false,
            timestamp: DateTime.now(),
            sessionId: _currentSessionId,
          ),
        ];
      }

      // Ensure we have a session
      if (_currentSessionId == null) {
        await createChatSession();
        if (_currentSessionId == null) {
          return null;
        }
      }

      // Try the AI chat endpoint first
      final messages = [
        {
          'role': 'user',
          'content': message,
        }
      ];

      final response = await _apiService.sendChatMessage(
        messages: messages,
        sessionId: _currentSessionId,
        purpose: 'chat',
        sessionType: 'conversation',
      );

      return response.when(
        success: (data, responseMessage) {
          final List<ChatMessage> chatMessages = [];
          
          // Add user message
          chatMessages.add(ChatMessage(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            message: message,
            isUser: true,
            timestamp: DateTime.now(),
            sessionId: _currentSessionId,
          ));

          // Add AI response
          final aiMessage = data['message'] as String? ?? '';
          if (aiMessage.isNotEmpty) {
            chatMessages.add(ChatMessage(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
              message: aiMessage,
              isUser: false,
              timestamp: DateTime.now(),
              sessionId: _currentSessionId,
            ));
          }

          return chatMessages;
        },
        error: (errorMessage, statusCode, errors) {
          // If AI chat endpoint fails (404), use communication system with contextual responses
          if (statusCode == 404) {
            appLogger.warning('AI chat endpoint not available, using communication system with contextual responses');
            return _sendMessageWithCommunication(message);
          }
          
          appLogger.error('Failed to send message and get AI response', {
            'errorMessage': errorMessage,
            'statusCode': statusCode,
          });
          return null;
        },
      );
    } catch (e) {
      appLogger.error('Error sending message and getting AI response', {'error': e.toString()});
      return null;
    }
  }

  // Send message with streaming response (Tsukiyo pattern)
  Future<Stream<String>?> sendMessageStream(String message) async {
    try {
      // Ensure we have a session
      if (_currentSessionId == null) {
        await createChatSession();
        if (_currentSessionId == null) {
          return null;
        }
      }

      // Try streaming chat endpoint first
      return await _sendStreamingMessage(message);
    } catch (e) {
      appLogger.error('Error sending streaming message', {'error': e.toString()});
      return null;
    }
  }

  // Send streaming message using the streaming endpoint
  Future<Stream<String>?> _sendStreamingMessage(String message) async {
    try {
      final messages = [
        {
          'role': 'user',
          'content': message,
        }
      ];

      // Use Dio to create a streaming request (Tsukiyo API)
      final response = await _apiService.dio.post(
        '/chat/stream',
        data: {
          'messages': messages,
          'session_id': _currentSessionId,
          'session_type': 'conversation',
          'purpose': 'chat',
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200) {
        // Create a stream from the response
        return response.data.stream.transform(utf8.decoder).transform(
          LineSplitter(),
        ).map((line) {
          // Parse SSE format
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              return '';
            }
            try {
              final json = jsonDecode(data);
              return json['content'] as String? ?? '';
            } catch (e) {
              return '';
            }
          }
          return '';
        }).where((content) => content.isNotEmpty);
      } else {
        appLogger.warning('Streaming endpoint not available, falling back to communication system');
        return null;
      }
    } catch (e) {
      appLogger.warning('Streaming chat failed, falling back to communication system', {'error': e.toString()});
      return null;
    }
  }

  // Send message using communication system (fallback when chat API fails)
  Future<List<ChatMessage>?> _sendMessageWithCommunication(String message) async {
    try {
      // Send user message via communication system first
      final userResponse = await _apiService.createCommunication(
        sessionId: _currentSessionId!,
        itemType: 'message',
        role: 'user',
        originalContent: message,
        consent: true,
      );

      return await userResponse.when(
        success: (data, responseMessage) async {
          final List<ChatMessage> chatMessages = [];
          
          // Add user message
          chatMessages.add(ChatMessage(
            id: data['id'] as String,
            message: message,
            isUser: true,
            timestamp: DateTime.parse(data['created_at'] as String),
            sessionId: _currentSessionId,
          ));

          // Generate a contextual AI response (not using journal endpoint)
          final aiMessage = _generateContextualAIResponse(message);
          
          // Send AI response via communication system
          final aiResponse = await _apiService.createCommunication(
            sessionId: _currentSessionId!,
            itemType: 'message',
            role: 'assistant',
            originalContent: aiMessage,
            consent: true,
          );

          return aiResponse.when(
            success: (aiData, aiResponseMessage) {
              // Add AI response
              chatMessages.add(ChatMessage(
                id: aiData['id'] as String,
                message: aiMessage,
                isUser: false,
                timestamp: DateTime.parse(aiData['created_at'] as String),
                sessionId: _currentSessionId,
              ));
              return chatMessages;
            },
            error: (errorMessage, statusCode, errors) {
              appLogger.error('Failed to send AI response', {
                'errorMessage': errorMessage,
                'statusCode': statusCode,
              });
              return chatMessages; // Return at least the user message
            },
          );
        },
        error: (errorMessage, statusCode, errors) async {
          appLogger.error('Failed to send user message', {
            'errorMessage': errorMessage,
            'statusCode': statusCode,
          });
          return null;
        },
      );
    } catch (e) {
      appLogger.error('Error in communication message sending', {'error': e.toString()});
      return null;
    }
  }

  // Get AI response using the AI summary endpoint with conversation context
  Future<String> _getAIResponseWithContext(String userMessage) async {
    try {
      // Try to get existing conversation history to build context
      final chatHistory = await getChatHistory(sessionId: _currentSessionId!);
      
      if (chatHistory.isNotEmpty) {
        // We have conversation history, try the AI summary endpoint
        appLogger.info('Attempting to get AI response using conversation context');
        
        final aiResponse = await _apiService.createAIJournalEntry(
          sessionId: _currentSessionId!,
          customContent: userMessage,
        );
        
        return aiResponse.when(
          success: (data, responseMessage) {
            // Extract AI response from the journal entry
            final content = data['content'] as String? ?? 
                           data['summary'] as String? ?? 
                           data['original_content'] as String? ?? '';
            
            if (content.isNotEmpty) {
              appLogger.info('Successfully got AI response from AI summary endpoint');
              return content;
            } else {
              appLogger.warning('AI summary endpoint returned empty content, using fallback');
              return _generateFallbackAIResponse(userMessage);
            }
          },
          error: (errorMessage, statusCode, errors) {
            appLogger.warning('AI summary endpoint failed, using fallback response', {
              'errorMessage': errorMessage,
              'statusCode': statusCode,
            });
            return _generateFallbackAIResponse(userMessage);
          },
        );
      } else {
        // No conversation history yet, create a journal entry first, then try AI summary
        appLogger.info('No conversation history, creating journal entry first for AI context');
        
        // Create a journal entry with the user's message to provide context
        final journalResponse = await _apiService.createJournalEntry(
          header: 'Chat Message',
          entryType: 'chat',
          sessionId: _currentSessionId!,
          originalContent: userMessage,
          consent: true,
        );
        
        return journalResponse.when(
          success: (journalData, journalMessage) async {
            // Now try the AI summary endpoint with the journal entry as context
            final aiResponse = await _apiService.createAIJournalEntry(
              sessionId: _currentSessionId!,
              customContent: userMessage,
            );
            
            return aiResponse.when(
              success: (data, responseMessage) {
                // Extract AI response from the journal entry
                final content = data['content'] as String? ?? 
                               data['summary'] as String? ?? 
                               data['original_content'] as String? ?? '';
                
                if (content.isNotEmpty) {
                  appLogger.info('Successfully got AI response from AI summary endpoint for first message');
                  return content;
                } else {
                  appLogger.warning('AI summary endpoint returned empty content for first message, using fallback');
                  return _generateFallbackAIResponse(userMessage);
                }
              },
              error: (errorMessage, statusCode, errors) {
                appLogger.warning('AI summary endpoint failed for first message, using fallback response', {
                  'errorMessage': errorMessage,
                  'statusCode': statusCode,
                });
                return _generateFallbackAIResponse(userMessage);
              },
            );
          },
          error: (errorMessage, statusCode, errors) {
            appLogger.warning('Failed to create journal entry for context, using fallback response', {
              'errorMessage': errorMessage,
              'statusCode': statusCode,
            });
            return _generateFallbackAIResponse(userMessage);
          },
        );
      }
    } catch (e) {
      appLogger.error('Error getting AI response with context', {'error': e.toString()});
      return _generateFallbackAIResponse(userMessage);
    }
  }

  // Generate contextual AI response for chat (not using journal endpoints)
  String _generateContextualAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Legal/court related responses
    if (message.contains('court') || message.contains('legal') || message.contains('lawyer') || message.contains('attorney')) {
      return "I understand you're dealing with legal matters. This can be incredibly stressful and overwhelming. Remember, you have rights and there are resources available to help you navigate this process. What specific aspect of your situation would you like to talk about?";
    }
    
    // Mental health and therapy responses
    if (message.contains('anxiety') || message.contains('stress') || message.contains('worried') || message.contains('nervous')) {
      return "It sounds like you're experiencing some anxiety or stress. These feelings are completely valid, especially when dealing with difficult situations. Would you like to talk about what's causing these feelings and explore some coping strategies?";
    }
    
    if (message.contains('depressed') || message.contains('sad') || message.contains('down') || message.contains('hopeless')) {
      return "I hear that you're going through a difficult time emotionally. It takes courage to acknowledge these feelings. You're not alone in this, and there are people and resources that can help. What would be most helpful for you right now?";
    }
    
    // Relationship and family responses
    if (message.contains('family') || message.contains('relationship') || message.contains('partner') || message.contains('spouse')) {
      return "Family and relationship dynamics can be complex and emotionally challenging. It sounds like you're navigating some difficult interpersonal situations. Would you like to explore how these relationships are affecting you and discuss ways to set healthy boundaries?";
    }
    
    // Work and career responses
    if (message.contains('work') || message.contains('job') || message.contains('career') || message.contains('boss')) {
      return "Work-related stress can significantly impact your overall well-being. It sounds like you're facing some challenges in your professional life. What aspects of your work situation are most concerning to you right now?";
    }
    
    // General supportive responses
    if (message.contains('help') || message.contains('support') || message.contains('advice')) {
      return "I'm here to listen and support you. It's important to remember that seeking help is a sign of strength, not weakness. What would be most helpful for you to talk about today?";
    }
    
    // Default empathetic response
    return "Thank you for sharing that with me. It sounds like you're going through a challenging time, and I want you to know that your feelings are valid. I'm here to listen and support you. What would you like to explore further?";
  }

  // Generate contextual fallback AI response (temporary until AI endpoint is available)
  String _generateFallbackAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Context-aware responses based on keywords
    if (message.contains('court') || message.contains('custody') || message.contains('legal')) {
      return "I understand you're dealing with legal matters. This can be incredibly stressful and overwhelming. Remember, you have rights and there are resources available to help you navigate this process. What specific aspect of your situation would you like to talk about?";
    }
    
    if (message.contains('scared') || message.contains('afraid') || message.contains('fear')) {
      return "I hear the fear in your words, and I want you to know that your feelings are completely valid. Fear is a natural response when facing difficult situations. You're not alone in this. What would help you feel safer right now?";
    }
    
    if (message.contains('help') || message.contains('support') || message.contains('need')) {
      return "You've taken an important step by reaching out. There are people and resources available to support you through this journey. What kind of support would feel most helpful to you right now?";
    }
    
    if (message.contains('alone') || message.contains('isolated') || message.contains('lonely')) {
      return "I want you to know that you're not alone, even when it feels that way. Many people have walked similar paths and found their way through. You have strength within you that you might not even realize. What's one small thing that could help you feel more connected today?";
    }
    
    if (message.contains('children') || message.contains('kids') || message.contains('child')) {
      return "I can hear how much your children mean to you. Protecting them while navigating difficult circumstances takes incredible strength. You're doing the best you can in a challenging situation. What's most important to you when it comes to your children's wellbeing?";
    }
    
    // Default trauma-informed responses
    final responses = [
      "I hear you, and I want you to know that your feelings are valid. Can you tell me more about what's coming up for you right now?",
      "Thank you for sharing that with me. It sounds like you're going through something really challenging. How are you feeling about it?",
      "I appreciate you opening up to me. What you're experiencing is a normal response to difficult circumstances. Would you like to explore some coping strategies together?",
      "I can sense that this is really important to you. Let's take a moment to breathe together. What would be most helpful for you right now?",
      "Your courage in sharing this is remarkable. Healing is a journey, and you don't have to walk it alone. What kind of support would feel most helpful to you?",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  // Send a user message (for backward compatibility)
  Future<ChatMessage?> sendUserMessage(String message) async {
    final messages = await sendMessageAndGetResponse(message);
    return messages?.isNotEmpty == true ? messages!.first : null;
  }

  // Get AI response (for backward compatibility)
  Future<ChatMessage?> getAIResponse(String userMessage, {String? sessionId}) async {
    final messages = await sendMessageAndGetResponse(userMessage);
    return messages?.length == 2 ? messages![1] : null;
  }


  // Clear current session
  void clearSession() {
    appLogger.info('Clearing current chat session', {'sessionId': _currentSessionId});
    _currentSessionId = null;
  }

  // Get current session info
  String? get currentSessionId => _currentSessionId;

  // Check if there's an active session
  bool get hasActiveSession => _currentSessionId != null;

  // Get all sessions (Tsukiyo pattern with local fallback)
  Future<List<Map<String, dynamic>>> getSessions({
    String sessionType = 'conversation',
  }) async {
    try {
      final response = await _apiService.dio.get('/sessions/', queryParameters: {
        'session_type': sessionType,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final sessions = data['sessions'] as List<dynamic>? ?? [];
        final sessionList = sessions.cast<Map<String, dynamic>>();
        
        // Save sessions locally for offline access
        await _saveSessionsLocally(sessionList);
        
        return sessionList;
      } else {
        appLogger.error('Failed to get sessions', {'statusCode': response.statusCode});
        return await _getSessionsLocally();
      }
    } catch (e) {
      // Handle 404 or other errors gracefully - sessions endpoint might not be implemented yet
      if (e.toString().contains('404')) {
        appLogger.warning('Sessions endpoint not available yet, using local storage');
        return await _getSessionsLocally();
      }
      appLogger.error('Error getting sessions', {'error': e.toString()});
      return await _getSessionsLocally();
    }
  }

  // Save sessions to local storage
  Future<void> _saveSessionsLocally(List<Map<String, dynamic>> sessions) async {
    try {
      final sessionsJson = jsonEncode(sessions);
      await _storage.write(key: _sessionsKey, value: sessionsJson);
      appLogger.debug('Saved ${sessions.length} sessions locally');
    } catch (e) {
      appLogger.error('Error saving sessions locally', {'error': e.toString()});
    }
  }

  // Get sessions from local storage
  Future<List<Map<String, dynamic>>> _getSessionsLocally() async {
    try {
      final sessionsJson = await _storage.read(key: _sessionsKey);
      
      if (sessionsJson != null) {
        final sessions = jsonDecode(sessionsJson) as List<dynamic>;
        final sessionList = sessions.cast<Map<String, dynamic>>();
        appLogger.debug('Loaded ${sessionList.length} sessions from local storage');
        return sessionList;
      }
      
      return [];
    } catch (e) {
      appLogger.error('Error loading sessions locally', {'error': e.toString()});
      return [];
    }
  }

  // Add a session to local storage
  Future<void> _addSessionLocally(Map<String, dynamic> session) async {
    try {
      final sessions = await _getSessionsLocally();
      
      // Check if session already exists
      final existingIndex = sessions.indexWhere((s) => s['id'] == session['id']);
      if (existingIndex >= 0) {
        sessions[existingIndex] = session;
      } else {
        sessions.add(session);
      }
      
      await _saveSessionsLocally(sessions);
      appLogger.debug('Added session to local storage', {'sessionId': session['id']});
    } catch (e) {
      appLogger.error('Error adding session locally', {'error': e.toString()});
    }
  }

  // Get specific session
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      final response = await _apiService.dio.get('/sessions/$sessionId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        appLogger.error('Failed to get session from API', {'sessionId': sessionId, 'statusCode': response.statusCode});
        // Fallback to local storage
        return await _getSessionLocally(sessionId);
      }
    } catch (e) {
      appLogger.warning('Error getting session from API, checking local storage', {'sessionId': sessionId, 'error': e.toString()});
      // Fallback to local storage
      return await _getSessionLocally(sessionId);
    }
  }

  // Get session from local storage
  Future<Map<String, dynamic>?> _getSessionLocally(String sessionId) async {
    try {
      final sessions = await _getSessionsLocally();
      final session = sessions.firstWhere(
        (s) => s['id'] == sessionId,
        orElse: () => <String, dynamic>{},
      );
      
      if (session.isNotEmpty) {
        appLogger.debug('Found session in local storage', {'sessionId': sessionId});
        return session;
      }
      
      return null;
    } catch (e) {
      appLogger.error('Error getting session from local storage', {'sessionId': sessionId, 'error': e.toString()});
      return null;
    }
  }


  // Switch to a different session
  Future<bool> switchToSession(String sessionId) async {
    try {
      final session = await getSession(sessionId);
      if (session != null) {
        _currentSessionId = sessionId;
        appLogger.info('Switched to session', {'sessionId': sessionId});
        return true;
      } else {
        appLogger.error('Session not found', {'sessionId': sessionId});
        return false;
      }
    } catch (e) {
      appLogger.error('Error switching to session', {'sessionId': sessionId, 'error': e.toString()});
      return false;
    }
  }

  // Update session name
  Future<bool> updateSessionName(String sessionId, String newName) async {
    try {
      final response = await _apiService.updateSessionName(
        sessionId: sessionId,
        name: newName,
      );
      
      return response.when(
        success: (data, statusCode) {
          appLogger.info('Successfully updated session name', {
            'sessionId': sessionId,
            'newName': newName,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to update session name', {
            'sessionId': sessionId,
            'newName': newName,
            'error': message,
            'statusCode': statusCode,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error updating session name', {
        'sessionId': sessionId,
        'newName': newName,
        'error': e.toString(),
      });
      return false;
    }
  }

  // Delete session
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await _apiService.deleteSession(sessionId: sessionId);
      
      return response.when(
        success: (data, statusCode) {
          appLogger.info('Successfully deleted session', {
            'sessionId': sessionId,
          });
          
          // Remove from local storage
          _removeSessionLocally(sessionId);
          
          // If this was the current session, clear it
          if (_currentSessionId == sessionId) {
            _currentSessionId = null;
          }
          
          return true;
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to delete session', {
            'sessionId': sessionId,
            'error': message,
            'statusCode': statusCode,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error deleting session', {
        'sessionId': sessionId,
        'error': e.toString(),
      });
      return false;
    }
  }

  // Remove session from local storage
  Future<void> _removeSessionLocally(String sessionId) async {
    try {
      final sessionsJson = await _storage.read(key: _sessionsKey);
      if (sessionsJson != null) {
        final List<dynamic> sessions = jsonDecode(sessionsJson);
        sessions.removeWhere((session) => session['id'] == sessionId);
        await _storage.write(key: _sessionsKey, value: jsonEncode(sessions));
        appLogger.info('Removed session from local storage', {'sessionId': sessionId});
      }
    } catch (e) {
      appLogger.error('Error removing session from local storage', {
        'sessionId': sessionId,
        'error': e.toString(),
      });
    }
  }

  // Get chat history for a specific session
  Future<List<Map<String, dynamic>>> getChatHistory({
    String? sessionId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final targetSessionId = sessionId ?? _currentSessionId;
      appLogger.info('Getting chat history', {'sessionId': targetSessionId, 'limit': limit, 'offset': offset});
      
      if (targetSessionId == null) {
        appLogger.warning('No session ID provided for chat history');
        return [];
      }

      final response = await _apiService.dio.get('/communications/', queryParameters: {
        'session_id': targetSessionId,
        'item_type': 'chat',
        'limit': limit,
        'offset': offset,
      });

      appLogger.info('Chat history API response', {'sessionId': targetSessionId, 'statusCode': response.statusCode});

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final communications = data['communications'] as List<dynamic>? ?? [];
        appLogger.info('Retrieved communications from API', {'sessionId': targetSessionId, 'count': communications.length});
        return communications.cast<Map<String, dynamic>>();
      } else {
        appLogger.error('Failed to get chat history from API', {'sessionId': targetSessionId, 'statusCode': response.statusCode});
        // Fallback to local storage
        return await _getChatHistoryLocally(targetSessionId);
      }
    } catch (e) {
      appLogger.warning('Error getting chat history from API, checking local storage', {'sessionId': sessionId, 'error': e.toString()});
      // Fallback to local storage
      final targetSessionId = sessionId ?? _currentSessionId;
      return await _getChatHistoryLocally(targetSessionId ?? '');
    }
  }

  // Get chat history from local storage
  Future<List<Map<String, dynamic>>> _getChatHistoryLocally(String sessionId) async {
    try {
      final historyKey = 'chat_history_$sessionId';
      final historyJson = await _storage.read(key: historyKey);
      
      if (historyJson != null) {
        final history = jsonDecode(historyJson) as List<dynamic>;
        final historyList = history.cast<Map<String, dynamic>>();
        appLogger.debug('Loaded ${historyList.length} messages from local storage', {'sessionId': sessionId});
        return historyList;
      }
      
      return [];
    } catch (e) {
      appLogger.error('Error loading chat history from local storage', {'sessionId': sessionId, 'error': e.toString()});
      return [];
    }
  }

  // Save chat history to local storage
  Future<void> saveChatHistoryLocally(String sessionId, List<Map<String, dynamic>> history) async {
    try {
      final historyKey = 'chat_history_$sessionId';
      final historyJson = jsonEncode(history);
      await _storage.write(key: historyKey, value: historyJson);
      appLogger.debug('Saved ${history.length} messages to local storage', {'sessionId': sessionId});
    } catch (e) {
      appLogger.error('Error saving chat history locally', {'sessionId': sessionId, 'error': e.toString()});
    }
  }

  // Create communication item (for sending messages)
  Future<Map<String, dynamic>?> createCommunication({
    required String sessionId,
    required String itemType,
    required String originalContent,
    String? role,
    String? redactedContent,
    bool consent = true,
  }) async {
    try {
      final response = await _apiService.dio.post('/communications/', data: {
        'session_id': sessionId,
        'item_type': itemType,
        'original_content': originalContent,
        if (role != null) 'role': role,
        if (redactedContent != null) 'redacted_content': redactedContent,
        'consent': consent,
      });

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        appLogger.error('Failed to create communication', {'statusCode': response.statusCode});
        return null;
      }
    } catch (e) {
      appLogger.error('Error creating communication', {'error': e.toString()});
      return null;
    }
  }
}

// Provider for ChatService
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ChatService(apiService);
});
