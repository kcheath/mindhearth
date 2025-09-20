import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_package.dart';

abstract class BillingRepository {
  /// Get current user balance
  Future<Result<int>> getBalance();

  /// Get billing status and warnings
  Future<Result<BillingStatus>> getBillingStatus();

  /// Get transaction history (ledger entries)
  Future<Result<List<LedgerEntry>>> getLedgerHistory({
    int? limit,
    int? offset,
  });

  /// Get purchase history
  Future<Result<List<Purchase>>> getPurchaseHistory({
    int? limit,
    int? offset,
  });

  /// Get available credit packages
  Future<Result<List<CreditPackage>>> getCreditPackages();

  /// Purchase credits
  Future<Result<Purchase>> purchaseCredits({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  });

  /// Gift credits to another user
  Future<Result<void>> giftCredits({
    required String recipientId,
    required int amount,
    String? message,
  });

  /// Validate a purchase (for IAP)
  Future<Result<bool>> validatePurchase({
    required String transactionId,
    required String productId,
    required String receipt,
  });

  /// Get usage analytics
  Future<Result<Map<String, dynamic>>> getUsageAnalytics();

  /// Check if operation is allowed (sufficient credits)
  Future<Result<bool>> checkOperationAllowed({
    required String operationType,
    required int estimatedCost,
  });

  /// Consume credits for an operation
  Future<Result<void>> consumeCredits({
    required String operationType,
    required int amount,
    String? description,
  });
}
