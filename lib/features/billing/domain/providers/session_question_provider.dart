import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// Session question tracking state
class SessionQuestionState {
  final Map<String, int> sessionQuestions;
  final int globalTotalQuestions;
  final int questionsPerCredit;
  final bool isLoading;
  final String? error;

  const SessionQuestionState({
    this.sessionQuestions = const {},
    this.globalTotalQuestions = 0,
    this.questionsPerCredit = 10,
    this.isLoading = false,
    this.error,
  });

  SessionQuestionState copyWith({
    Map<String, int>? sessionQuestions,
    int? globalTotalQuestions,
    int? questionsPerCredit,
    bool? isLoading,
    String? error,
  }) {
    return SessionQuestionState(
      sessionQuestions: sessionQuestions ?? this.sessionQuestions,
      globalTotalQuestions: globalTotalQuestions ?? this.globalTotalQuestions,
      questionsPerCredit: questionsPerCredit ?? this.questionsPerCredit,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Session question tracking notifier
class SessionQuestionNotifier extends StateNotifier<SessionQuestionState> {
  final ApiService _apiService;

  SessionQuestionNotifier(this._apiService) : super(const SessionQuestionState());

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

  /// Deduct credits for questions when threshold is reached
  Future<void> _deductCreditsForQuestions() async {
    try {
      final creditsToDeduct = state.creditsUsed;
      
      appLogger.info('Deducting credits for questions', {
        'creditsToDeduct': creditsToDeduct,
        'globalQuestions': state.globalTotalQuestions,
      });

      final response = await _apiService.dio.post(
        '/billing/session-questions/add',
        data: {
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
        'creditsToDeduct': state.creditsUsed,
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
