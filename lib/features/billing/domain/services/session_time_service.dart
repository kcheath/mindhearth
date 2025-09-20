import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// Session time service for credit consumption
class SessionTimeService {
  final ApiService _apiService;

  SessionTimeService(this._apiService);

  /// Consume credits for session time
  Future<CreditConsumptionResult> consumeCreditsForSession({
    required String sessionId,
    required int durationSeconds,
  }) async {
    try {
      appLogger.info('Consuming credits for session time', {
        'sessionId': sessionId,
        'durationSeconds': durationSeconds,
      });

      final response = await _apiService.dio.post(
        '/session-time/$sessionId/consume-credits',
        data: {
          'duration_seconds': durationSeconds,
        },
      );

      if (response.statusCode == 200) {
        final result = CreditConsumptionResult.fromJson(response.data);
        
        appLogger.info('Credits consumed successfully for session time', {
          'sessionId': sessionId,
          'durationSeconds': durationSeconds,
          'creditsConsumed': result.creditsConsumed,
          'newBalance': result.newBalance,
        });

        return result;
      } else {
        throw Exception('Failed to consume credits for session time: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.error('Failed to consume credits for session time', {
        'error': e.toString(),
        'sessionId': sessionId,
        'durationSeconds': durationSeconds,
      });
      rethrow;
    }
  }

  /// Calculate session cost based on duration
  int calculateSessionCost(int durationSeconds) {
    const costPerMinute = 1; // 1 credit per minute
    final minutes = durationSeconds / 60;
    return (minutes * costPerMinute).ceil();
  }

  /// Get session time cost estimation
  Future<CostEstimation> estimateSessionTimeCost(int durationSeconds) async {
    try {
      final estimatedCost = calculateSessionCost(durationSeconds);
      
      return CostEstimation(
        sizeBytes: 0, // Not applicable for session time
        estimatedCost: estimatedCost,
        currency: 'credits',
        notes: 'Session time cost: ${durationSeconds}s',
      );
    } catch (e) {
      appLogger.error('Failed to estimate session time cost', {
        'error': e.toString(),
        'durationSeconds': durationSeconds,
      });
      rethrow;
    }
  }

  /// Check if user has sufficient credits for session time
  Future<bool> hasSufficientCreditsForSession(int durationSeconds) async {
    try {
      final cost = calculateSessionCost(durationSeconds);
      
      // Get current balance
      final balanceResponse = await _apiService.dio.get('/billing/balance');
      if (balanceResponse.statusCode == 200) {
        final balance = balanceResponse.data['balance'] as int;
        return balance >= cost;
      }
      
      return false;
    } catch (e) {
      appLogger.error('Failed to check sufficient credits for session', {
        'error': e.toString(),
        'durationSeconds': durationSeconds,
      });
      return false;
    }
  }
}

/// Session time service provider
final sessionTimeServiceProvider = Provider<SessionTimeService>((ref) {
  return SessionTimeService(ref.watch(apiServiceProvider));
});
