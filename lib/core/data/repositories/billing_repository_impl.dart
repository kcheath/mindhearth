import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
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

      return response.when(
        success: (data, message) {
          final balance = data['balance'] as int;
          appLogger.info('✅ Retrieved balance: $balance credits');
          return Result.success(balance);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get balance: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting balance: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get balance: $e'));
    }
  }

  @override
  Future<Result<BillingStatus>> getBillingStatus() async {
    try {
      appLogger.info('📊 Getting billing status');

      final response = await _apiService.get('/billing/status');

      return response.when(
        success: (data, message) {
          final status = BillingStatus.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Retrieved billing status: ${status.status}');
          return Result.success(status);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get billing status: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting billing status: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get billing status: $e'));
    }
  }

  @override
  Future<Result<List<LedgerEntry>>> getLedgerHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('📋 Getting ledger history');

      final response = await _apiService.get(
        '/billing/ledger',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      return response.when(
        success: (data, message) {
          final entries = (data['entries'] as List)
              .map((json) => LedgerEntry.fromJson(json as Map<String, dynamic>))
              .toList();
          appLogger.info('✅ Retrieved ${entries.length} ledger entries');
          return Result.success(entries);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get ledger history: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting ledger history: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get ledger history: $e'));
    }
  }

  @override
  Future<Result<List<Purchase>>> getPurchaseHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('🛒 Getting purchase history');

      final response = await _apiService.get(
        '/billing/purchases',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      return response.when(
        success: (data, message) {
          final purchases = (data['purchases'] as List)
              .map((json) => Purchase.fromJson(json as Map<String, dynamic>))
              .toList();
          appLogger.info('✅ Retrieved ${purchases.length} purchases');
          return Result.success(purchases);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get purchase history: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting purchase history: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get purchase history: $e'));
    }
  }

  @override
  Future<Result<List<CreditPackage>>> getCreditPackages() async {
    try {
      appLogger.info('📦 Getting credit packages');

      final response = await _apiService.get('/billing/packages');

      return response.when(
        success: (data, message) {
          final packages = (data['packages'] as List)
              .map((json) => CreditPackage.fromJson(json as Map<String, dynamic>))
              .toList();
          appLogger.info('✅ Retrieved ${packages.length} credit packages');
          return Result.success(packages);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get credit packages: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting credit packages: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get credit packages: $e'));
    }
  }

  @override
  Future<Result<Purchase>> purchaseCredits({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      appLogger.info('💳 Purchasing credits for package: $packageId');

      final response = await _apiService.post(
        '/billing/purchase',
        data: {
          'package_id': packageId,
          'payment_method': paymentMethod,
          if (paymentData != null) 'payment_data': paymentData,
        },
      );

      return response.when(
        success: (data, message) {
          final purchase = Purchase.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Purchased credits: ${purchase.id}');
          return Result.success(purchase);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to purchase credits: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception purchasing credits: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to purchase credits: $e'));
    }
  }

  @override
  Future<Result<void>> giftCredits({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    try {
      appLogger.info('🎁 Gifting $amount credits to user: $recipientId');

      final response = await _apiService.post(
        '/billing/gift',
        data: {
          'recipient_id': recipientId,
          'amount': amount,
          if (message != null) 'message': message,
        },
      );

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Gifted $amount credits to $recipientId');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to gift credits: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception gifting credits: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to gift credits: $e'));
    }
  }

  @override
  Future<Result<bool>> validatePurchase({
    required String transactionId,
    required String productId,
    required String receipt,
  }) async {
    try {
      appLogger.info('✅ Validating purchase');

      final response = await _apiService.post(
        '/billing/validate-purchase',
        data: {
          'transaction_id': transactionId,
          'product_id': productId,
          'receipt': receipt,
        },
      );

      return response.when(
        success: (data, message) {
          final isValid = data['valid'] as bool;
          appLogger.info('✅ Purchase validation result: $isValid');
          return Result.success(isValid);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to validate purchase: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception validating purchase: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to validate purchase: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUsageAnalytics() async {
    try {
      appLogger.info('📊 Getting usage analytics');

      final response = await _apiService.get('/billing/usage-analytics');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Retrieved usage analytics');
          return Result.success(data as Map<String, dynamic>);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get usage analytics: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting usage analytics: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get usage analytics: $e'));
    }
  }

  @override
  Future<Result<bool>> checkOperationAllowed({
    required String operationType,
    required int estimatedCost,
  }) async {
    try {
      appLogger.info('🔍 Checking operation allowance');

      final response = await _apiService.post(
        '/billing/check-operation',
        data: {
          'operation_type': operationType,
          'estimated_cost': estimatedCost,
        },
      );

      return response.when(
        success: (data, message) {
          final isAllowed = data['allowed'] as bool;
          appLogger.info('✅ Operation allowance: $isAllowed');
          return Result.success(isAllowed);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to check operation: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception checking operation: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to check operation: $e'));
    }
  }

  @override
  Future<Result<void>> consumeCredits({
    required String operationType,
    required int amount,
    String? description,
  }) async {
    try {
      appLogger.info('💸 Consuming credits');

      final response = await _apiService.post(
        '/billing/consume-credits',
        data: {
          'operation_type': operationType,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Consumed $amount credits for $operationType');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to consume credits: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception consuming credits: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to consume credits: $e'));
    }
  }
}