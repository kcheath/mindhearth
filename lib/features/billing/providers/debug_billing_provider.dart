import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/providers/usecase_providers.dart';
import 'package:mindhearth/core/domain/usecases/debug_billing_usecases.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Debug billing state
class DebugBillingState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? healthStatus;
  final Map<String, dynamic>? billingMode;
  final List<Map<String, dynamic>> operationChecks;

  const DebugBillingState({
    this.isLoading = false,
    this.error,
    this.healthStatus,
    this.billingMode,
    this.operationChecks = const [],
  });

  DebugBillingState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? healthStatus,
    Map<String, dynamic>? billingMode,
    List<Map<String, dynamic>>? operationChecks,
  }) {
    return DebugBillingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      healthStatus: healthStatus ?? this.healthStatus,
      billingMode: billingMode ?? this.billingMode,
      operationChecks: operationChecks ?? this.operationChecks,
    );
  }
}

/// Debug billing notifier
class DebugBillingNotifier extends StateNotifier<DebugBillingState> {
  final SeedCreditsUseCase _seedCreditsUseCase;
  final TopUpCreditsUseCase _topUpCreditsUseCase;
  final SimulatePurchaseUseCase _simulatePurchaseUseCase;
  final ResetBillingDataUseCase _resetBillingDataUseCase;
  final GetBillingHealthUseCase _getBillingHealthUseCase;
  final GetBillingModeUseCase _getBillingModeUseCase;
  final CheckOperationUseCase _checkOperationUseCase;

  DebugBillingNotifier({
    required SeedCreditsUseCase seedCreditsUseCase,
    required TopUpCreditsUseCase topUpCreditsUseCase,
    required SimulatePurchaseUseCase simulatePurchaseUseCase,
    required ResetBillingDataUseCase resetBillingDataUseCase,
    required GetBillingHealthUseCase getBillingHealthUseCase,
    required GetBillingModeUseCase getBillingModeUseCase,
    required CheckOperationUseCase checkOperationUseCase,
  }) : _seedCreditsUseCase = seedCreditsUseCase,
       _topUpCreditsUseCase = topUpCreditsUseCase,
       _simulatePurchaseUseCase = simulatePurchaseUseCase,
       _resetBillingDataUseCase = resetBillingDataUseCase,
       _getBillingHealthUseCase = getBillingHealthUseCase,
       _getBillingModeUseCase = getBillingModeUseCase,
       _checkOperationUseCase = checkOperationUseCase,
       super(const DebugBillingState());

  /// Check if debug mode is available
  bool get isDebugMode => DebugConfig.isDebugMode;

  /// Seed credits for testing
  Future<bool> seedCredits({
    required int credits,
  }) async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for seeding credits');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _seedCreditsUseCase.call(credits);

      return result.when(
        success: (data) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Credits seeded successfully', {
            'credits': credits,
            'response': data,
          });
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to seed credits', {
            'error': error.message,
            'credits': credits,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error seeding credits', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to seed credits',
      );
      return false;
    }
  }

  /// Top up credits for current user
  Future<bool> topUpCredits({required int credits}) async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for topping up credits');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _topUpCreditsUseCase.call(credits);

      return result.when(
        success: (data) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Credits topped up successfully', {
            'credits': credits,
            'response': data,
          });
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to top up credits', {
            'error': error.message,
            'credits': credits,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error topping up credits', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to top up credits',
      );
      return false;
    }
  }

  /// Simulate a purchase for testing
  Future<bool> simulatePurchase({
    required int credits,
  }) async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for simulating purchase');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _simulatePurchaseUseCase.call(credits);

      return result.when(
        success: (data) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Purchase simulated successfully', {
            'credits': credits,
            'response': data,
          });
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to simulate purchase', {
            'error': error.message,
            'credits': credits,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error simulating purchase', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to simulate purchase',
      );
      return false;
    }
  }


  /// Reset all billing data
  Future<bool> resetBillingData() async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for resetting billing data');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _resetBillingDataUseCase.call();

      return result.when(
        success: (data) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Billing data reset successfully', {
            'response': data,
          });
          return true;
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to reset billing data', {
            'error': error.message,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error resetting billing data', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset billing data',
      );
      return false;
    }
  }

  /// Get billing system health
  Future<void> loadBillingHealth() async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for loading billing health');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _getBillingHealthUseCase.call();

      result.when(
        success: (data) {
          state = state.copyWith(
            isLoading: false,
            healthStatus: data,
          );
          appLogger.info('Billing health loaded successfully', {
            'response': data,
          });
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to load billing health', {
            'error': error.message,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading billing health', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load billing health',
      );
    }
  }

  /// Get billing mode information
  Future<void> loadBillingMode() async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for loading billing mode');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _getBillingModeUseCase.call();

      result.when(
        success: (data) {
          state = state.copyWith(
            isLoading: false,
            billingMode: data,
          );
          appLogger.info('Billing mode loaded successfully', {
            'response': data,
          });
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to load billing mode', {
            'error': error.message,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading billing mode', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load billing mode',
      );
    }
  }

  /// Check operation permission
  Future<void> checkOperation({required String operationType}) async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for checking operation');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _checkOperationUseCase.call(operationType);

      result.when(
        success: (data) {
          final updatedChecks = List<Map<String, dynamic>>.from(
            state.operationChecks,
          );
          updatedChecks.add({
            'operationType': operationType,
            'result': data,
            'timestamp': DateTime.now().toIso8601String(),
          });

          state = state.copyWith(
            isLoading: false,
            operationChecks: updatedChecks,
          );
          appLogger.info('Operation check completed', {
            'operationType': operationType,
            'response': data,
          });
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Failed to check operation', {
            'error': error.message,
            'operationType': operationType,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error checking operation', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check operation',
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Debug billing provider
final debugBillingProvider = StateNotifierProvider<DebugBillingNotifier, DebugBillingState>((ref) {
  return DebugBillingNotifier(
    seedCreditsUseCase: ref.watch(seedCreditsUseCaseProvider),
    topUpCreditsUseCase: ref.watch(topUpCreditsUseCaseProvider),
    simulatePurchaseUseCase: ref.watch(simulatePurchaseUseCaseProvider),
    resetBillingDataUseCase: ref.watch(resetBillingDataUseCaseProvider),
    getBillingHealthUseCase: ref.watch(getBillingHealthUseCaseProvider),
    getBillingModeUseCase: ref.watch(getBillingModeUseCaseProvider),
    checkOperationUseCase: ref.watch(checkOperationUseCaseProvider),
  );
});
