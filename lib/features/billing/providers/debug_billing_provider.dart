import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/services/debug_billing_service.dart';
import 'package:mindhearth/core/services/api_service.dart';
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
  final DebugBillingService _debugService;

  DebugBillingNotifier(this._debugService) : super(const DebugBillingState());

  /// Check if debug mode is available
  bool get isDebugMode => DebugConfig.isDebugMode;

  /// Seed credits for testing
  Future<bool> seedCredits({
    required String userId,
    required int credits,
  }) async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for seeding credits');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _debugService.seedCredits(
        userId: userId,
        credits: credits,
      );

      return response.when(
        success: (data, statusCode) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Credits seeded successfully', {
            'userId': userId,
            'credits': credits,
            'response': data,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to seed credits', {
            'error': message,
            'userId': userId,
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

      final response = await _debugService.topUpCredits(credits: credits);

      return response.when(
        success: (data, statusCode) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Credits topped up successfully', {
            'credits': credits,
            'response': data,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to top up credits', {
            'error': message,
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

  /// Simulate a purchase
  Future<bool> simulatePurchase({
    required String userId,
    required int credits,
  }) async {
    if (!isDebugMode) {
      appLogger.warning('Debug mode not available for simulating purchase');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _debugService.simulatePurchase(
        userId: userId,
        credits: credits,
      );

      return response.when(
        success: (data, statusCode) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Purchase simulated successfully', {
            'userId': userId,
            'credits': credits,
            'response': data,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to simulate purchase', {
            'error': message,
            'userId': userId,
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

      final response = await _debugService.resetBillingData();

      return response.when(
        success: (data, statusCode) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Billing data reset successfully', {
            'response': data,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to reset billing data', {
            'error': message,
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

      final response = await _debugService.getBillingHealth();

      response.when(
        success: (data, statusCode) {
          state = state.copyWith(
            isLoading: false,
            healthStatus: data,
          );
          appLogger.info('Billing health loaded successfully', {
            'response': data,
          });
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load billing health', {
            'error': message,
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

      final response = await _debugService.getBillingMode();

      response.when(
        success: (data, statusCode) {
          state = state.copyWith(
            isLoading: false,
            billingMode: data,
          );
          appLogger.info('Billing mode loaded successfully', {
            'response': data,
          });
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load billing mode', {
            'error': message,
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

      final response = await _debugService.checkOperation(
        operationType: operationType,
      );

      response.when(
        success: (data, statusCode) {
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
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to check operation', {
            'error': message,
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

/// Debug billing service provider
final debugBillingServiceProvider = Provider<DebugBillingService>((ref) {
  final apiService = ApiService();
  return DebugBillingService(apiService);
});

/// Debug billing provider
final debugBillingProvider = StateNotifierProvider<DebugBillingNotifier, DebugBillingState>((ref) {
  final debugService = ref.read(debugBillingServiceProvider);
  return DebugBillingNotifier(debugService);
});
