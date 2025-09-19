import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/api_response.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Debug service for billing operations in development mode
class DebugBillingService {
  final ApiService _apiService;

  DebugBillingService(this._apiService);

  /// Check if debug mode is available
  bool get isDebugMode => DebugConfig.isDebugMode;

  /// Seed credits for testing
  Future<ApiResponse<Map<String, dynamic>>> seedCredits({
    required String userId,
    required int credits,
  }) async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Seeding credits for testing', {
        'userId': userId,
        'credits': credits,
      });

      final response = await _apiService.dio.post(
        DebugConfig.getDevEndpoint('seed_credits'),
        data: {
          'user_id': userId,
          'credits': credits,
        },
      );

      appLogger.info('Credits seeded successfully', {
        'userId': userId,
        'credits': credits,
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to seed credits', {
        'error': e.toString(),
        'userId': userId,
        'credits': credits,
      });
      return ApiError(message: 'Failed to seed credits: ${e.toString()}');
    }
  }

  /// Top up credits for current user
  Future<ApiResponse<Map<String, dynamic>>> topUpCredits({
    required int credits,
  }) async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Topping up credits for testing', {
        'credits': credits,
      });

      final response = await _apiService.dio.post(
        DebugConfig.getDevEndpoint('top_up_credits'),
        data: {
          'credits': credits,
        },
      );

      appLogger.info('Credits topped up successfully', {
        'credits': credits,
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to top up credits', {
        'error': e.toString(),
        'credits': credits,
      });
      return ApiError(message: 'Failed to top up credits: ${e.toString()}');
    }
  }

  /// Simulate a purchase
  Future<ApiResponse<Map<String, dynamic>>> simulatePurchase({
    required String userId,
    required int credits,
  }) async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Simulating purchase for testing', {
        'userId': userId,
        'credits': credits,
      });

      final response = await _apiService.dio.post(
        DebugConfig.getDevEndpoint('simulate_purchase'),
        data: {
          'user_id': userId,
          'credits': credits,
        },
      );

      appLogger.info('Purchase simulated successfully', {
        'userId': userId,
        'credits': credits,
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to simulate purchase', {
        'error': e.toString(),
        'userId': userId,
        'credits': credits,
      });
      return ApiError(message: 'Failed to simulate purchase: ${e.toString()}');
    }
  }

  /// Reset all billing data
  Future<ApiResponse<Map<String, dynamic>>> resetBillingData() async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Resetting billing data for testing');

      final response = await _apiService.dio.post(
        DebugConfig.getDevEndpoint('reset_billing'),
      );

      appLogger.info('Billing data reset successfully', {
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to reset billing data', {
        'error': e.toString(),
      });
      return ApiError(message: 'Failed to reset billing data: ${e.toString()}');
    }
  }

  /// Get billing system health
  Future<ApiResponse<Map<String, dynamic>>> getBillingHealth() async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Checking billing system health');

      final response = await _apiService.dio.get(
        DebugConfig.getDevEndpoint('billing_health'),
      );

      appLogger.info('Billing health retrieved', {
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to get billing health', {
        'error': e.toString(),
      });
      return ApiError(message: 'Failed to get billing health: ${e.toString()}');
    }
  }

  /// Get billing mode information
  Future<ApiResponse<Map<String, dynamic>>> getBillingMode() async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Getting billing mode information');

      final response = await _apiService.dio.get(
        DebugConfig.getDevEndpoint('billing_mode'),
      );

      appLogger.info('Billing mode retrieved', {
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to get billing mode', {
        'error': e.toString(),
      });
      return ApiError(message: 'Failed to get billing mode: ${e.toString()}');
    }
  }

  /// Check if operation is allowed
  Future<ApiResponse<Map<String, dynamic>>> checkOperation({
    required String operationType,
  }) async {
    if (!isDebugMode) {
      throw StateError('Debug mode not available');
    }

    try {
      appLogger.info('Checking operation permission', {
        'operationType': operationType,
      });

      final response = await _apiService.dio.post(
        DebugConfig.getDevEndpoint('check_operation'),
        data: {
          'operation_type': operationType,
        },
      );

      appLogger.info('Operation check completed', {
        'operationType': operationType,
        'response': response.data,
      });

      return ApiSuccess(data: response.data);
    } catch (e) {
      appLogger.error('Failed to check operation', {
        'error': e.toString(),
        'operationType': operationType,
      });
      return ApiError(message: 'Failed to check operation: ${e.toString()}');
    }
  }
}
