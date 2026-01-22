import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/entities/result.dart';

/// Use case for getting current balance
class GetCurrentBalanceUseCase {
  final BillingRepository _billingRepository;

  GetCurrentBalanceUseCase(this._billingRepository);

  Future<Result<int>> call() async {
    return await _billingRepository.getCurrentBalance();
  }
}

/// Use case for sending heartbeat to keep connection alive
class SendHeartbeatUseCase {
  final BillingRepository _billingRepository;

  SendHeartbeatUseCase(this._billingRepository);

  Future<Result<void>> call() async {
    return await _billingRepository.sendHeartbeat();
  }
}
