import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// AI summary service for credit consumption
class AISummaryService {
  final ApiService _apiService;

  AISummaryService(this._apiService);

  /// Get AI summary configuration
  Future<Map<String, dynamic>> getAISummaryConfig() async {
    try {
      appLogger.info('Getting AI summary configuration');

      final response = await _apiService.dio.get('/api/billing/ai-summary-config');

      if (response.statusCode == 200) {
        final config = response.data as Map<String, dynamic>;
        
        appLogger.info('AI summary configuration retrieved', {
          'config': config,
        });

        return config;
      } else {
        throw Exception('Failed to get AI summary config: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.error('Failed to get AI summary configuration', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Generate AI summary and consume credits
  Future<CreditConsumptionResult> generateAISummary({
    required String sessionId,
    String? title,
    String? content,
  }) async {
    try {
      appLogger.info('Generating AI summary', {
        'sessionId': sessionId,
        'title': title,
      });

      final response = await _apiService.dio.post(
        '/api/journals/ai-summary',
        data: {
          'session_id': sessionId,
          'title': title,
          'content': content,
        },
      );

      if (response.statusCode == 200) {
        final result = CreditConsumptionResult.fromJson(response.data);
        
        appLogger.info('AI summary generated and credits consumed', {
          'sessionId': sessionId,
          'creditsConsumed': result.creditsConsumed,
          'newBalance': result.newBalance,
        });

        return result;
      } else {
        throw Exception('Failed to generate AI summary: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.error('Failed to generate AI summary', {
        'error': e.toString(),
        'sessionId': sessionId,
      });
      rethrow;
    }
  }

  /// Check if user has sufficient credits for AI summary
  Future<bool> hasSufficientCreditsForAISummary() async {
    try {
      // Get AI summary configuration
      final config = await getAISummaryConfig();
      final creditsRequired = config['ai_summary_credits'] ?? 1;
      
      // Get current balance
      final balanceResponse = await _apiService.dio.get('/api/billing/balance');
      if (balanceResponse.statusCode == 200) {
        final balance = balanceResponse.data['balance'] as int;
        return balance >= creditsRequired;
      }
      
      return false;
    } catch (e) {
      appLogger.error('Failed to check sufficient credits for AI summary', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get AI summary cost estimation
  Future<CostEstimation> estimateAISummaryCost() async {
    try {
      final config = await getAISummaryConfig();
      final creditsRequired = config['ai_summary_credits'] ?? 1;
      
      return CostEstimation(
        sizeBytes: 0, // Not applicable for AI summary
        estimatedCost: creditsRequired,
        currency: 'credits',
        notes: 'AI summary generation cost',
      );
    } catch (e) {
      appLogger.error('Failed to estimate AI summary cost', {
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Check if session has communications for AI summary
  Future<bool> canGenerateAISummary(String sessionId) async {
    try {
      appLogger.info('Checking if session can generate AI summary', {
        'sessionId': sessionId,
      });

      final response = await _apiService.dio.get('/api/sessions/$sessionId/communications');

      if (response.statusCode == 200) {
        final communications = response.data as List;
        final canGenerate = communications.isNotEmpty;
        
        appLogger.info('AI summary generation check completed', {
          'sessionId': sessionId,
          'canGenerate': canGenerate,
          'communicationCount': communications.length,
        });

        return canGenerate;
      } else {
        return false;
      }
    } catch (e) {
      appLogger.error('Failed to check AI summary generation capability', {
        'error': e.toString(),
        'sessionId': sessionId,
      });
      return false;
    }
  }
}

/// AI summary service provider
final aiSummaryServiceProvider = Provider<AISummaryService>((ref) {
  return AISummaryService(ref.watch(apiServiceProvider));
});
