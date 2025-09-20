import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// Session question tracking state
class SessionQuestionState {
  final Map<String, int> sessionQuestions;
  final int globalTotalQuestions;
  final int questionsPerCredit;
  final bool isLoading;
  final String? error;
  final int creditsUsed;
  final int questionsRemainingInCurrentCredit;

  const SessionQuestionState({
    this.sessionQuestions = const {},
    this.globalTotalQuestions = 0,
    this.questionsPerCredit = 10,
    this.isLoading = false,
    this.error,
    this.creditsUsed = 0,
    this.questionsRemainingInCurrentCredit = 0,
  });

  SessionQuestionState copyWith({
    Map<String, int>? sessionQuestions,
    int? globalTotalQuestions,
    int? questionsPerCredit,
    bool? isLoading,
    String? error,
    int? creditsUsed,
    int? questionsRemainingInCurrentCredit,
  }) {
    return SessionQuestionState(
      sessionQuestions: sessionQuestions ?? this.sessionQuestions,
      globalTotalQuestions: globalTotalQuestions ?? this.globalTotalQuestions,
      questionsPerCredit: questionsPerCredit ?? this.questionsPerCredit,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      questionsRemainingInCurrentCredit: questionsRemainingInCurrentCredit ?? this.questionsRemainingInCurrentCredit,
    );
  }

  /// Check if we should deduct credits based on questions per credit
  bool get shouldDeductCredit {
    return globalTotalQuestions > 0 && globalTotalQuestions % questionsPerCredit == 0;
  }
}

/// Session question tracking notifier
class SessionQuestionNotifier extends StateNotifier<SessionQuestionState> {
  final ApiService _apiService;

  SessionQuestionNotifier(this._apiService) : super(const SessionQuestionState()) {
    _loadQuestionCountsFromBackend();
  }

  /// Add questions to session and global counter
  Future<void> addQuestions(int questions, {String? sessionId}) async {
    if (sessionId == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Update local state
      final currentSessionQuestions = state.sessionQuestions[sessionId] ?? 0;
      final newSessionQuestions = currentSessionQuestions + questions;
      final newGlobalQuestions = state.globalTotalQuestions + questions;

      final updatedSessionQuestions = Map<String, int>.from(state.sessionQuestions);
      updatedSessionQuestions[sessionId] = newSessionQuestions;

      state = state.copyWith(
        sessionQuestions: updatedSessionQuestions,
        globalTotalQuestions: newGlobalQuestions,
        isLoading: false,
      );

      // Persist question counts to backend
      await _persistQuestionCountsToBackend(sessionId, newSessionQuestions, newGlobalQuestions);

      // Check if we should deduct credits
      if (state.shouldDeductCredit) {
        await _deductCreditsForQuestions();
      }

      appLogger.info('Questions added to session', {
        'sessionId': sessionId,
        'questions': questions,
        'sessionTotal': newSessionQuestions,
        'globalTotal': newGlobalQuestions,
        'creditsUsed': state.creditsUsed,
        'questionsRemaining': state.questionsRemainingInCurrentCredit,
      });
    } catch (e) {
      appLogger.error('Failed to add questions to session', {
        'error': e.toString(),
        'sessionId': sessionId,
        'questions': questions,
      });
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add questions: ${e.toString()}',
      );
    }
  }

  /// Load question counts from backend
  Future<void> _loadQuestionCountsFromBackend() async {
    try {
      appLogger.info('Loading question counts from backend');

      final response = await _apiService.dio.get('/billing/session-questions/status');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final sessionQuestions = Map<String, int>.from(data['session_questions'] ?? {});
        final globalTotalQuestions = data['global_total_questions'] as int? ?? 0;
        final questionsPerCredit = data['questions_per_credit'] as int? ?? 10;

        state = state.copyWith(
          sessionQuestions: sessionQuestions,
          globalTotalQuestions: globalTotalQuestions,
          questionsPerCredit: questionsPerCredit,
        );

        appLogger.info('Question counts loaded from backend', {
          'sessionQuestions': sessionQuestions,
          'globalTotalQuestions': globalTotalQuestions,
          'questionsPerCredit': questionsPerCredit,
        });
      }
    } catch (e) {
      appLogger.error('Failed to load question counts from backend', {
        'error': e.toString(),
      });
      // Don't throw error - allow app to continue with default state
    }
  }

  /// Persist question counts to backend
  Future<void> _persistQuestionCountsToBackend(String sessionId, int sessionQuestions, int globalQuestions) async {
    try {
      appLogger.info('Persisting question counts to backend', {
        'sessionId': sessionId,
        'sessionQuestions': sessionQuestions,
        'globalQuestions': globalQuestions,
      });

      final response = await _apiService.dio.post(
        '/billing/session-questions/track',
        data: {
          'session_id': sessionId,
          'session_questions': sessionQuestions,
          'global_questions': globalQuestions,
          'questions_per_credit': state.questionsPerCredit,
        },
      );

      if (response.statusCode == 200) {
        appLogger.info('Question counts persisted successfully', {
          'sessionId': sessionId,
          'sessionQuestions': sessionQuestions,
          'globalQuestions': globalQuestions,
          'response': response.data,
        });
      }
    } catch (e) {
      appLogger.error('Failed to persist question counts to backend', {
        'error': e.toString(),
        'sessionId': sessionId,
        'sessionQuestions': sessionQuestions,
        'globalQuestions': globalQuestions,
      });
      // Don't throw error - allow local state to continue even if backend persistence fails
    }
  }

  /// Deduct credits for questions when threshold is reached
  Future<void> _deductCreditsForQuestions() async {
    try {
      final creditsToDeduct = state.globalTotalQuestions ~/ state.questionsPerCredit;
      
      appLogger.info('Deducting credits for questions', {
        'creditsToDeduct': creditsToDeduct,
        'globalQuestions': state.globalTotalQuestions,
      });

      final response = await _apiService.dio.post(
        '/billing/session-questions/add',
        queryParameters: {
          'questions': state.globalTotalQuestions,
          'credits_to_deduct': creditsToDeduct,
        },
      );

      if (response.statusCode == 200) {
        appLogger.info('Credits deducted successfully for questions', {
          'creditsDeducted': creditsToDeduct,
          'response': response.data,
        });
      }
    } catch (e) {
      appLogger.error('Failed to deduct credits for questions', {
        'error': e.toString(),
        'globalQuestions': state.globalTotalQuestions,
      });
    }
  }

  /// Get questions for a specific session
  int getSessionQuestions(String sessionId) {
    return state.sessionQuestions[sessionId] ?? 0;
  }

  /// Get global total questions
  int get globalTotalQuestions => state.globalTotalQuestions;

  /// Get credits used based on global questions
  int get creditsUsed => state.globalTotalQuestions ~/ state.questionsPerCredit;

  /// Get questions remaining in current credit
  int get questionsRemainingInCurrentCredit =>
      state.questionsPerCredit - (state.globalTotalQuestions % state.questionsPerCredit);

  /// Check if should deduct credit
  bool get shouldDeductCredit =>
      state.globalTotalQuestions % state.questionsPerCredit == 0 &&
      state.globalTotalQuestions > 0;

  /// Reset session questions
  void resetSessionQuestions(String sessionId) {
    final updatedSessionQuestions = Map<String, int>.from(state.sessionQuestions);
    updatedSessionQuestions.remove(sessionId);
    
    state = state.copyWith(sessionQuestions: updatedSessionQuestions);
    
    appLogger.info('Session questions reset', {
      'sessionId': sessionId,
    });
  }

  /// Reset all questions
  void resetAllQuestions() {
    state = state.copyWith(
      sessionQuestions: {},
      globalTotalQuestions: 0,
    );
    
    appLogger.info('All session questions reset');
  }

  /// Refresh question counts from backend
  Future<void> refreshQuestionCounts() async {
    await _loadQuestionCountsFromBackend();
  }
}

/// Session question provider
final sessionQuestionProvider = StateNotifierProvider<SessionQuestionNotifier, SessionQuestionState>(
  (ref) => SessionQuestionNotifier(ref.watch(apiServiceProvider)),
);

/// Session question tracking provider
final sessionQuestionTrackingProvider = Provider<SessionQuestionTracking>((ref) {
  final state = ref.watch(sessionQuestionProvider);
  
  return SessionQuestionTracking(
    sessionId: '', // This would be set by the calling context
    sessionQuestions: state.sessionQuestions.values.fold(0, (sum, count) => sum + count),
    globalTotalQuestions: state.globalTotalQuestions,
    questionsPerCredit: state.questionsPerCredit,
    creditsUsed: state.globalTotalQuestions ~/ state.questionsPerCredit,
    questionsRemainingInCurrentCredit: state.questionsPerCredit - (state.globalTotalQuestions % state.questionsPerCredit),
    shouldDeductCredit: state.globalTotalQuestions % state.questionsPerCredit == 0 && state.globalTotalQuestions > 0,
  );
});

/// Questions remaining provider
final questionsRemainingProvider = Provider<int>((ref) {
  final state = ref.watch(sessionQuestionProvider);
  return state.questionsPerCredit - (state.globalTotalQuestions % state.questionsPerCredit);
});

/// Credits used provider
final creditsUsedProvider = Provider<int>((ref) {
  final state = ref.watch(sessionQuestionProvider);
  return state.globalTotalQuestions ~/ state.questionsPerCredit;
});
