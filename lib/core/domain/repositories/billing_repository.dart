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
  Future<Result<Map<String, dynamic>>> getUsageAnalytics(int periodDays);

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

  // Debug methods for development
  /// Seed credits for testing
  Future<Result<Map<String, dynamic>>> seedCredits(int credits);
  
  /// Top up credits for current user
  Future<Result<Map<String, dynamic>>> topUpCredits(int credits);
  
  /// Simulate a purchase for testing
  Future<Result<Map<String, dynamic>>> simulatePurchase(int credits);
  
  /// Reset all billing data
  Future<Result<Map<String, dynamic>>> resetBillingData();
  
  /// Get billing system health
  Future<Result<Map<String, dynamic>>> getBillingHealth();
  
  /// Get billing mode information
  Future<Result<Map<String, dynamic>>> getBillingMode();
  
  /// Check operation permission
  Future<Result<Map<String, dynamic>>> checkOperation(String operationType);
  
  /// Get current balance (for balance stream)
  Future<Result<int>> getCurrentBalance();
  
  /// Send heartbeat to keep connection alive
  Future<Result<void>> sendHeartbeat();
  
  /// Add session questions
  Future<Result<void>> addSessionQuestions({
    required String sessionId,
    required int questions,
  });
  
  /// Get session question count
  Future<Result<int>> getSessionQuestionCount(String sessionId);
  
  /// Get session question status
  Future<Result<Map<String, dynamic>>> getSessionQuestionStatus();
}
