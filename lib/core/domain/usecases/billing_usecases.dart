import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_package.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';

/// Use case for getting billing status
class GetBillingStatusUseCase {
  final BillingRepository _billingRepository;
  
  GetBillingStatusUseCase(this._billingRepository);
  
  Future<Result<BillingStatus>> call() async {
    return await _billingRepository.getBillingStatus();
  }
}

/// Use case for purchasing credits
class PurchaseCreditsUseCase {
  final BillingRepository _billingRepository;
  
  PurchaseCreditsUseCase(this._billingRepository);
  
  Future<Result<Purchase>> call({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate input
    if (packageId.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Package ID is required',
      ));
    }
    
    if (paymentMethod.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Payment method is required',
      ));
    }
    
    return await _billingRepository.purchaseCredits(
      packageId: packageId,
      paymentMethod: paymentMethod,
      metadata: metadata,
    );
  }
}

/// Use case for getting credit packages
class GetCreditPackagesUseCase {
  final BillingRepository _billingRepository;
  
  GetCreditPackagesUseCase(this._billingRepository);
  
  Future<Result<List<CreditPackage>>> call() async {
    return await _billingRepository.getCreditPackages();
  }
}

/// Use case for getting purchase history
class GetPurchaseHistoryUseCase {
  final BillingRepository _billingRepository;
  
  GetPurchaseHistoryUseCase(this._billingRepository);
  
  Future<Result<List<Purchase>>> call({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _billingRepository.getPurchaseHistory(
      limit: limit,
      offset: offset,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}

/// Use case for getting ledger entries
class GetLedgerEntriesUseCase {
  final BillingRepository _billingRepository;
  
  GetLedgerEntriesUseCase(this._billingRepository);
  
  Future<Result<List<LedgerEntry>>> call({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _billingRepository.getLedgerEntries(
      limit: limit,
      offset: offset,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}

/// Use case for checking billing status
class CheckBillingStatusUseCase {
  final BillingRepository _billingRepository;
  
  CheckBillingStatusUseCase(this._billingRepository);
  
  Future<Result<bool>> call() async {
    final result = await _billingRepository.checkBillingStatus();
    
    if (result.isFailure) {
      return Result.failure(result.error!);
    }
    
    // Return true if billing is active and user has credits
    final status = result.data!;
    return Result.success(status.isActive && status.currentBalance > 0);
  }
}

/// Use case for getting usage analytics
class GetUsageAnalyticsUseCase {
  final BillingRepository _billingRepository;
  
  GetUsageAnalyticsUseCase(this._billingRepository);
  
  Future<Result<Map<String, dynamic>>> call({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _billingRepository.getUsageAnalytics(
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
