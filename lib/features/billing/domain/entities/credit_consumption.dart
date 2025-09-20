import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_consumption.freezed.dart';
part 'credit_consumption.g.dart';

/// Credit consumption entity for tracking usage
@freezed
class CreditConsumption with _$CreditConsumption {
  const factory CreditConsumption({
    required String id,
    required String userId,
    required int delta,
    required int balanceAfter,
    required String type,
    String? applicationId,
    String? sessionId,
    String? notes,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    String? idempotencyKey,
  }) = _CreditConsumption;

  factory CreditConsumption.fromJson(Map<String, dynamic> json) =>
      _$CreditConsumptionFromJson(json);
}

/// Credit consumption types
enum CreditConsumptionType {
  grant('grant'),
  chatDebit('chat_debit'),
  docDebit('doc_debit'),
  purchase('purchase'),
  giftIn('gift_in'),
  giftOut('gift_out'),
  adjustment('adjustment'),
  sessionUsage('session_usage'),
  carryDeduction('carry_deduction'),
  aiSummaryDebit('ai_summary_debit');

  const CreditConsumptionType(this.value);
  final String value;
}

/// Credit status levels
enum CreditStatus {
  normal('normal'),
  lowWarning('low_warning'),
  critical('critical'),
  blocked('blocked');

  const CreditStatus(this.value);
  final String value;
}

/// Credit consumption result
@freezed
class CreditConsumptionResult with _$CreditConsumptionResult {
  const factory CreditConsumptionResult({
    required int creditsConsumed,
    required int newBalance,
    required int durationSeconds,
    String? sessionId,
    String? notes,
  }) = _CreditConsumptionResult;

  factory CreditConsumptionResult.fromJson(Map<String, dynamic> json) =>
      _$CreditConsumptionResultFromJson(json);
}

/// Session question tracking
@freezed
class SessionQuestionTracking with _$SessionQuestionTracking {
  const factory SessionQuestionTracking({
    required String sessionId,
    required int sessionQuestions,
    required int globalTotalQuestions,
    required int questionsPerCredit,
    required int creditsUsed,
    required int questionsRemainingInCurrentCredit,
    required bool shouldDeductCredit,
  }) = _SessionQuestionTracking;

  factory SessionQuestionTracking.fromJson(Map<String, dynamic> json) =>
      _$SessionQuestionTrackingFromJson(json);
}

/// Usage analytics
@freezed
class UsageAnalytics with _$UsageAnalytics {
  const factory UsageAnalytics({
    required int periodDays,
    required int totalConsumed,
    required int totalGranted,
    required int netUsage,
    required Map<String, int> breakdownByType,
    required List<CreditConsumption> recentEntries,
  }) = _UsageAnalytics;

  factory UsageAnalytics.fromJson(Map<String, dynamic> json) =>
      _$UsageAnalyticsFromJson(json);
}

/// Cost estimation
@freezed
class CostEstimation with _$CostEstimation {
  const factory CostEstimation({
    required int sizeBytes,
    required int estimatedCost,
    required String currency,
    String? notes,
  }) = _CostEstimation;

  factory CostEstimation.fromJson(Map<String, dynamic> json) =>
      _$CostEstimationFromJson(json);
}

/// Credit status check result
@freezed
class CreditStatusCheck with _$CreditStatusCheck {
  const factory CreditStatusCheck({
    required bool allowed,
    required int currentBalance,
    String? reason,
    int? requiredCredits,
    List<String>? warnings,
  }) = _CreditStatusCheck;

  factory CreditStatusCheck.fromJson(Map<String, dynamic> json) =>
      _$CreditStatusCheckFromJson(json);
}
