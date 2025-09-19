import 'package:dio/dio.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/api_response.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Billing service for managing credits, purchases, and billing operations
/// Aligned with Mindhearth's principles of transparency and user empowerment
class BillingService {
  final ApiService _apiService;

  BillingService(this._apiService);

  /// Get current user balance
  Future<ApiResponse<int>> getBalance() async {
    try {
      appLogger.info('Getting user balance');
      
      final response = await _apiService.dio.get('/billing/balance');
      
      appLogger.info('Balance retrieved successfully', {
        'balance': response.data['balance'],
      });
      
      return ApiSuccess(
        data: response.data['balance'] as int,
      );
    } on DioException catch (e) {
      appLogger.error('Error getting balance', {
        'error': e.toString(),
        'response': e.response?.data,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to get balance',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error getting balance', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Get comprehensive billing status
  Future<ApiResponse<BillingStatus>> getBillingStatus() async {
    try {
      appLogger.info('Getting billing status');
      
      final response = await _apiService.dio.get('/billing/status');
      
      final billingStatus = BillingStatus.fromJson(response.data);
      
      appLogger.info('Billing status retrieved successfully', {
        'status': billingStatus.status,
        'balance': billingStatus.currentBalance,
      });
      
      return ApiSuccess(
        data: billingStatus,
      );
    } on DioException catch (e) {
      appLogger.error('Error getting billing status', {
        'error': e.toString(),
        'response': e.response?.data,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to get billing status',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error getting billing status', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Get user's credit ledger with pagination
  Future<ApiResponse<List<LedgerEntry>>> getLedger({
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      appLogger.info('Getting credit ledger', {
        'limit': limit,
        'before': before?.toIso8601String(),
      });
      
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      
      if (before != null) {
        queryParams['before'] = before.toIso8601String();
      }
      
      final response = await _apiService.dio.get(
        '/billing/ledger',
        queryParameters: queryParams,
      );
      
      final entries = (response.data['entries'] as List)
          .map((entry) => LedgerEntry.fromJson(entry))
          .toList();
      
      appLogger.info('Credit ledger retrieved successfully', {
        'entryCount': entries.length,
      });
      
      return ApiSuccess(
        data: entries,
      );
    } on DioException catch (e) {
      appLogger.error('Error getting credit ledger', {
        'error': e.toString(),
        'response': e.response?.data,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to get credit ledger',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error getting credit ledger', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Check if an operation is allowed based on current balance
  Future<ApiResponse<Map<String, dynamic>>> checkOperation(String operationType) async {
    try {
      appLogger.info('Checking operation allowance', {
        'operationType': operationType,
      });
      
      final response = await _apiService.dio.post('/billing/check-operation', data: {
        'operation_type': operationType,
      });
      
      appLogger.info('Operation check completed', {
        'operationType': operationType,
        'allowed': response.data['allowed'],
      });
      
      return ApiSuccess(
        data: response.data,
      );
    } on DioException catch (e) {
      appLogger.error('Error checking operation', {
        'error': e.toString(),
        'response': e.response?.data,
        'operationType': operationType,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to check operation',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error checking operation', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Validate a purchase with the backend
  Future<ApiResponse<Purchase>> validatePurchase({
    required String provider,
    required String productId,
    required String transactionId,
    required String receiptData,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      appLogger.info('Validating purchase', {
        'provider': provider,
        'productId': productId,
        'transactionId': transactionId,
      });
      
      final response = await _apiService.dio.post(
        '/billing/validate-purchase/$provider',
        data: {
          'product_id': productId,
          'transaction_id': transactionId,
          'receipt_data': receiptData,
          'metadata': metadata,
        },
      );
      
      final purchase = Purchase.fromJson(response.data);
      
      appLogger.info('Purchase validated successfully', {
        'purchaseId': purchase.id,
        'status': purchase.status,
      });
      
      return ApiSuccess(
        data: purchase,
      );
    } on DioException catch (e) {
      appLogger.error('Error validating purchase', {
        'error': e.toString(),
        'response': e.response?.data,
        'provider': provider,
        'productId': productId,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to validate purchase',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error validating purchase', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Get purchase history
  Future<ApiResponse<List<Purchase>>> getPurchaseHistory({
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      appLogger.info('Getting purchase history', {
        'limit': limit,
        'before': before?.toIso8601String(),
      });
      
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      
      if (before != null) {
        queryParams['before'] = before.toIso8601String();
      }
      
      final response = await _apiService.dio.get(
        '/billing/purchases',
        queryParameters: queryParams,
      );
      
      final purchases = (response.data['purchases'] as List)
          .map((purchase) => Purchase.fromJson(purchase))
          .toList();
      
      appLogger.info('Purchase history retrieved successfully', {
        'purchaseCount': purchases.length,
      });
      
      return ApiSuccess(
        data: purchases,
      );
    } on DioException catch (e) {
      appLogger.error('Error getting purchase history', {
        'error': e.toString(),
        'response': e.response?.data,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to get purchase history',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error getting purchase history', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Gift credits to another user
  Future<ApiResponse<LedgerEntry>> giftCredits({
    required String recipientUserId,
    required int amount,
    String? message,
  }) async {
    try {
      appLogger.info('Gifting credits', {
        'recipientUserId': recipientUserId,
        'amount': amount,
      });
      
      final response = await _apiService.dio.post('/billing/gift', data: {
        'recipient_user_id': recipientUserId,
        'amount': amount,
        'message': message,
      });
      
      final ledgerEntry = LedgerEntry.fromJson(response.data);
      
      appLogger.info('Credits gifted successfully', {
        'ledgerEntryId': ledgerEntry.id,
        'amount': amount,
      });
      
      return ApiSuccess(
        data: ledgerEntry,
      );
    } on DioException catch (e) {
      appLogger.error('Error gifting credits', {
        'error': e.toString(),
        'response': e.response?.data,
        'recipientUserId': recipientUserId,
        'amount': amount,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to gift credits',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error gifting credits', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Purchase credits directly
  Future<ApiResponse<Purchase>> purchaseCredits({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      appLogger.info('Purchasing credits', {
        'packageId': packageId,
        'paymentMethod': paymentMethod,
      });
      
      final response = await _apiService.dio.post('/billing/purchase', data: {
        'package_id': packageId,
        'payment_method': paymentMethod,
        'payment_data': paymentData,
      });
      
      final purchase = Purchase.fromJson(response.data);
      
      appLogger.info('Credits purchased successfully', {
        'purchaseId': purchase.id,
        'packageId': packageId,
      });
      
      return ApiSuccess(
        data: purchase,
      );
    } on DioException catch (e) {
      appLogger.error('Error purchasing credits', {
        'error': e.toString(),
        'response': e.response?.data,
        'packageId': packageId,
        'paymentMethod': paymentMethod,
      });
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to purchase credits',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      appLogger.error('Unexpected error purchasing credits', {'error': e.toString()});
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
