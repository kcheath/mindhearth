import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// Document cost service for credit consumption
class DocumentCostService {
  final ApiService _apiService;

  DocumentCostService(this._apiService);

  /// Estimate document processing cost
  Future<CostEstimation> estimateDocumentCost(int sizeBytes) async {
    try {
      appLogger.info('Estimating document cost', {
        'sizeBytes': sizeBytes,
      });

      final response = await _apiService.dio.post(
        '/billing/estimate-document-cost',
        data: {
          'size_bytes': sizeBytes,
        },
      );

      if (response.statusCode == 200) {
        final result = CostEstimation.fromJson(response.data);
        
        appLogger.info('Document cost estimated successfully', {
          'sizeBytes': sizeBytes,
          'estimatedCost': result.estimatedCost,
        });

        return result;
      } else {
        throw Exception('Failed to estimate document cost: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.error('Failed to estimate document cost', {
        'error': e.toString(),
        'sizeBytes': sizeBytes,
      });
      rethrow;
    }
  }

  /// Confirm document processing and deduct credits
  Future<CreditConsumptionResult> confirmDocumentProcessing({
    required String documentId,
    required int sizeBytes,
  }) async {
    try {
      appLogger.info('Confirming document processing', {
        'documentId': documentId,
        'sizeBytes': sizeBytes,
      });

      final response = await _apiService.dio.post(
        '/billing/confirm-document',
        data: {
          'document_id': documentId,
          'size_bytes': sizeBytes,
        },
      );

      if (response.statusCode == 200) {
        final result = CreditConsumptionResult.fromJson(response.data);
        
        appLogger.info('Document processing confirmed and credits deducted', {
          'documentId': documentId,
          'sizeBytes': sizeBytes,
          'creditsConsumed': result.creditsConsumed,
          'newBalance': result.newBalance,
        });

        return result;
      } else {
        throw Exception('Failed to confirm document processing: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.error('Failed to confirm document processing', {
        'error': e.toString(),
        'documentId': documentId,
        'sizeBytes': sizeBytes,
      });
      rethrow;
    }
  }

  /// Calculate document cost based on size
  int calculateDocumentCost(int sizeBytes) {
    // Simple size-based pricing model
    // 1 credit per MB, minimum 1 credit
    const bytesPerMB = 1024 * 1024;
    final cost = (sizeBytes / bytesPerMB).ceil();
    return cost.clamp(1, 100); // Minimum 1, maximum 100 credits
  }

  /// Check if user has sufficient credits for document processing
  Future<bool> hasSufficientCreditsForDocument(int sizeBytes) async {
    try {
      final cost = calculateDocumentCost(sizeBytes);
      
      // Get current balance
      final balanceResponse = await _apiService.dio.get('/billing/balance');
      if (balanceResponse.statusCode == 200) {
        final balance = balanceResponse.data['balance'] as int;
        return balance >= cost;
      }
      
      return false;
    } catch (e) {
      appLogger.error('Failed to check sufficient credits for document', {
        'error': e.toString(),
        'sizeBytes': sizeBytes,
      });
      return false;
    }
  }

  /// Get document cost breakdown
  Map<String, dynamic> getDocumentCostBreakdown(int sizeBytes) {
    final cost = calculateDocumentCost(sizeBytes);
    final sizeMB = sizeBytes / (1024 * 1024);
    
    return {
      'size_bytes': sizeBytes,
      'size_mb': sizeMB.toStringAsFixed(2),
      'cost_credits': cost,
      'cost_per_mb': 1,
      'currency': 'credits',
    };
  }
}

/// Document cost service provider
final documentCostServiceProvider = Provider<DocumentCostService>((ref) {
  return DocumentCostService(ref.watch(apiServiceProvider));
});
