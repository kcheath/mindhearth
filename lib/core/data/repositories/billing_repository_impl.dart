import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_package.dart';
import 'package:mindhearth/core/utils/logger.dart';

class BillingRepositoryImpl implements BillingRepository {
  final ApiService _apiService;

  BillingRepositoryImpl(this._apiService);

  @override
  Future<Result<int>> getBalance() async {
    try {
      appLogger.info('💰 Getting user balance');

      final response = await _apiService.get('/billing/balance');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final balance = data['balance'] as int;
        appLogger.info('✅ Retrieved balance: $balance credits');
        return Result.success(balance);
      } else {
        appLogger.error('❌ Failed to get balance: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get balance');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting balance: $e');
      return Result.failure('Failed to get balance: $e');
    }
  }

  @override
  Future<Result<BillingStatus>> getBillingStatus() async {
    try {
      appLogger.info('📊 Getting billing status');

      final response = await _apiService.get('/billing/status');

      if (response.isSuccess) {
        final status = BillingStatus.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Retrieved billing status: ${status.status}');
        return Result.success(status);
      } else {
        appLogger.error('❌ Failed to get billing status: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get billing status');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting billing status: $e');
      return Result.failure('Failed to get billing status: $e');
    }
  }

  @override
  Future<Result<List<LedgerEntry>>> getLedgerHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('📋 Getting ledger history', extra: {
        'limit': limit,
        'offset': offset,
      });

      final response = await _apiService.get(
        '/billing/ledger',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final entries = (data['entries'] as List)
            .map((json) => LedgerEntry.fromJson(json as Map<String, dynamic>))
            .toList();
        appLogger.info('✅ Retrieved ${entries.length} ledger entries');
        return Result.success(entries);
      } else {
        appLogger.error('❌ Failed to get ledger history: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get ledger history');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting ledger history: $e');
      return Result.failure('Failed to get ledger history: $e');
    }
  }

  @override
  Future<Result<List<Purchase>>> getPurchaseHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('🛒 Getting purchase history', extra: {
        'limit': limit,
        'offset': offset,
      });

      final response = await _apiService.get(
        '/billing/purchases',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final purchases = (data['purchases'] as List)
            .map((json) => Purchase.fromJson(json as Map<String, dynamic>))
            .toList();
        appLogger.info('✅ Retrieved ${purchases.length} purchases');
        return Result.success(purchases);
      } else {
        appLogger.error('❌ Failed to get purchase history: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get purchase history');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting purchase history: $e');
      return Result.failure('Failed to get purchase history: $e');
    }
  }

  @override
  Future<Result<List<CreditPackage>>> getCreditPackages() async {
    try {
      appLogger.info('📦 Getting credit packages');

      final response = await _apiService.get('/billing/packages');

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final packages = (data['packages'] as List)
            .map((json) => CreditPackage.fromJson(json as Map<String, dynamic>))
            .toList();
        appLogger.info('✅ Retrieved ${packages.length} credit packages');
        return Result.success(packages);
      } else {
        appLogger.error('❌ Failed to get credit packages: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get credit packages');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting credit packages: $e');
      return Result.failure('Failed to get credit packages: $e');
    }
  }

  @override
  Future<Result<Purchase>> purchaseCredits({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      appLogger.info('💳 Purchasing credits', extra: {
        'packageId': packageId,
        'paymentMethod': paymentMethod,
      });

      final response = await _apiService.post(
        '/billing/purchase',
        data: {
          'package_id': packageId,
          'payment_method': paymentMethod,
          if (paymentData != null) 'payment_data': paymentData,
        },
      );

      if (response.isSuccess) {
        final purchase = Purchase.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Purchased credits: ${purchase.id}');
        return Result.success(purchase);
      } else {
        appLogger.error('❌ Failed to purchase credits: ${response.error}');
        return Result.failure(response.error ?? 'Failed to purchase credits');
      }
    } catch (e) {
      appLogger.error('💥 Exception purchasing credits: $e');
      return Result.failure('Failed to purchase credits: $e');
    }
  }

  @override
  Future<Result<void>> giftCredits({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    try {
      appLogger.info('🎁 Gifting credits', extra: {
        'recipientId': recipientId,
        'amount': amount,
      });

      final response = await _apiService.post(
        '/billing/gift',
        data: {
          'recipient_id': recipientId,
          'amount': amount,
          if (message != null) 'message': message,
        },
      );

      if (response.isSuccess) {
        appLogger.info('✅ Gifted $amount credits to $recipientId');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to gift credits: ${response.error}');
        return Result.failure(response.error ?? 'Failed to gift credits');
      }
    } catch (e) {
      appLogger.error('💥 Exception gifting credits: $e');
      return Result.failure('Failed to gift credits: $e');
    }
  }

  @override
  Future<Result<bool>> validatePurchase({
    required String transactionId,
    required String productId,
    required String receipt,
  }) async {
    try {
      appLogger.info('✅ Validating purchase', extra: {
        'transactionId': transactionId,
        'productId': productId,
      });

      final response = await _apiService.post(
        '/billing/validate-purchase',
        data: {
          'transaction_id': transactionId,
          'product_id': productId,
          'receipt': receipt,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final isValid = data['valid'] as bool;
        appLogger.info('✅ Purchase validation result: $isValid');
        return Result.success(isValid);
      } else {
        appLogger.error('❌ Failed to validate purchase: ${response.error}');
        return Result.failure(response.error ?? 'Failed to validate purchase');
      }
    } catch (e) {
      appLogger.error('💥 Exception validating purchase: $e');
      return Result.failure('Failed to validate purchase: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUsageAnalytics() async {
    try {
      appLogger.info('📊 Getting usage analytics');

      final response = await _apiService.get('/billing/usage-analytics');

      if (response.isSuccess) {
        appLogger.info('✅ Retrieved usage analytics');
        return Result.success(response.data as Map<String, dynamic>);
      } else {
        appLogger.error('❌ Failed to get usage analytics: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get usage analytics');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting usage analytics: $e');
      return Result.failure('Failed to get usage analytics: $e');
    }
  }

  @override
  Future<Result<bool>> checkOperationAllowed({
    required String operationType,
    required int estimatedCost,
  }) async {
    try {
      appLogger.info('🔍 Checking operation allowance', extra: {
        'operationType': operationType,
        'estimatedCost': estimatedCost,
      });

      final response = await _apiService.post(
        '/billing/check-operation',
        data: {
          'operation_type': operationType,
          'estimated_cost': estimatedCost,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final isAllowed = data['allowed'] as bool;
        appLogger.info('✅ Operation allowance: $isAllowed');
        return Result.success(isAllowed);
      } else {
        appLogger.error('❌ Failed to check operation: ${response.error}');
        return Result.failure(response.error ?? 'Failed to check operation');
      }
    } catch (e) {
      appLogger.error('💥 Exception checking operation: $e');
      return Result.failure('Failed to check operation: $e');
    }
  }

  @override
  Future<Result<void>> consumeCredits({
    required String operationType,
    required int amount,
    String? description,
  }) async {
    try {
      appLogger.info('💸 Consuming credits', extra: {
        'operationType': operationType,
        'amount': amount,
        'description': description,
      });

      final response = await _apiService.post(
        '/billing/consume-credits',
        data: {
          'operation_type': operationType,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );

      if (response.isSuccess) {
        appLogger.info('✅ Consumed $amount credits for $operationType');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to consume credits: ${response.error}');
        return Result.failure(response.error ?? 'Failed to consume credits');
      }
    } catch (e) {
      appLogger.error('💥 Exception consuming credits: $e');
      return Result.failure('Failed to consume credits: $e');
    }
  }
}
