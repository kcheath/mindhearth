import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/models/session_state.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/core/providers/api_providers.dart';

/// Session state notifier
class SessionNotifier extends StateNotifier<SessionState> {
  final ApiService _apiService;

  SessionNotifier(this._apiService) : super(const SessionState());

  /// Load sessions
  Future<void> loadSessions({String? sessionType}) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.getSessions(
        limit: 100,
        offset: 0,
        sessionType: sessionType,
      );
      
      response.when(
        success: (data, message) {
          // Handle both direct array response and wrapped response
          List<dynamic> sessionsList;
          if (data is List) {
            // Backend returns sessions array directly
            sessionsList = data;
          } else if (data is Map<String, dynamic> && data.containsKey('sessions')) {
            // Backend returns sessions wrapped in object
            sessionsList = data['sessions'] as List<dynamic>? ?? [];
          } else {
            // Fallback to empty list
            sessionsList = [];
          }
          
          final sessions = sessionsList
              .map((sessionData) => Session.fromJson(sessionData as Map<String, dynamic>))
              .toList();
          
          state = state.loadSessions(sessions);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('GET', '/sessions/', 200, {
              'count': sessions.length,
              'sessionType': sessionType,
            });
          }
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('GET', '/sessions/', statusCode ?? 500, message);
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to load sessions: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('GET', '/sessions/', 500, e.toString());
      }
    }
  }

  /// Create new session
  Future<Session?> createSession({
    String? name,
    String sessionType = 'conversation',
    String? purpose,
  }) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.createSession(
        name: name,
        sessionType: sessionType,
        purpose: purpose,
      );
      
      return response.when(
        success: (data, message) {
          final session = Session.fromJson(data);
          state = state.addSession(session);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('POST', '/sessions/', 201, {
              'sessionId': session.id,
              'name': session.name,
              'sessionType': session.sessionType,
            });
          }
          
          return session;
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('POST', '/sessions/', statusCode ?? 500, message);
          }
          
          return null;
        },
      );
    } catch (e) {
      state = state.setError('Failed to create session: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('POST', '/sessions/', 500, e.toString());
      }
      
      return null;
    }
  }

  /// Set current session
  void setCurrentSession(Session session) {
    state = state.setCurrentSession(session);
    
    if (LoggingConfig.enableApiLogs) {
      appLogger.apiRequest('SELECT', '/sessions/${session.id}', {
        'sessionId': session.id,
        'name': session.name,
      });
    }
  }

  /// Clear current session
  void clearCurrentSession() {
    state = state.clearCurrentSession();
    
    if (LoggingConfig.enableApiLogs) {
      appLogger.apiRequest('CLEAR', '/sessions/', {});
    }
  }

  /// Get session by ID
  Session? getSessionById(String id) {
    return state.getSessionById(id);
  }

  /// Refresh sessions
  Future<void> refreshSessions({String? sessionType}) async {
    await loadSessions(sessionType: sessionType);
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.setLoading(loading);
  }
}

/// Session state provider
final sessionNotifierProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SessionNotifier(apiService);
});

/// Session state provider (read-only)
final sessionStateProvider = Provider<SessionState>((ref) {
  return ref.watch(sessionNotifierProvider);
});

/// Current session provider
final currentSessionProvider = Provider<Session?>((ref) {
  return ref.watch(sessionStateProvider).currentSession;
});

/// Sessions list provider
final sessionsProvider = Provider<List<Session>>((ref) {
  return ref.watch(sessionStateProvider).sessions;
});

/// Session count provider
final sessionCountProvider = Provider<int>((ref) {
  return ref.watch(sessionStateProvider).sessionCount;
});
