import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/entities/result.dart';

/// Use case for seeding credits in debug mode
class SeedCreditsUseCase {
  final BillingRepository _billingRepository;

  SeedCreditsUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call(int credits) async {
    return await _billingRepository.seedCredits(credits);
  }
}

/// Use case for topping up credits in debug mode
class TopUpCreditsUseCase {
  final BillingRepository _billingRepository;

  TopUpCreditsUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call(int credits) async {
    return await _billingRepository.topUpCredits(credits);
  }
}

/// Use case for simulating a purchase in debug mode
class SimulatePurchaseUseCase {
  final BillingRepository _billingRepository;

  SimulatePurchaseUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call(int credits) async {
    return await _billingRepository.simulatePurchase(credits);
  }
}

/// Use case for resetting billing data in debug mode
class ResetBillingDataUseCase {
  final BillingRepository _billingRepository;

  ResetBillingDataUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call() async {
    return await _billingRepository.resetBillingData();
  }
}

/// Use case for getting billing health status
class GetBillingHealthUseCase {
  final BillingRepository _billingRepository;

  GetBillingHealthUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call() async {
    return await _billingRepository.getBillingHealth();
  }
}

/// Use case for getting billing mode information
class GetBillingModeUseCase {
  final BillingRepository _billingRepository;

  GetBillingModeUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call() async {
    return await _billingRepository.getBillingMode();
  }
}

/// Use case for checking operation permissions
class CheckOperationUseCase {
  final BillingRepository _billingRepository;

  CheckOperationUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call(String operationType) async {
    return await _billingRepository.checkOperation(operationType);
  }
}
