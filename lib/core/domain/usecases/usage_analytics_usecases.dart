import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';

/// Use case for getting usage analytics
class GetUsageAnalyticsUseCase {
  final BillingRepository _billingRepository;

  GetUsageAnalyticsUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call(int periodDays) async {
    return await _billingRepository.getUsageAnalytics(periodDays);
  }
}
