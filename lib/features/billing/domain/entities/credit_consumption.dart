/// Credit consumption entity for tracking usage
class CreditConsumption {
  final String id;
  final String userId;
  final int delta;
  final int balanceAfter;
  final String type;
  final String? applicationId;
  final String? sessionId;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String? idempotencyKey;

  const CreditConsumption({
    required this.id,
    required this.userId,
    required this.delta,
    required this.balanceAfter,
    required this.type,
    this.applicationId,
    this.sessionId,
    this.notes,
    this.metadata,
    required this.createdAt,
    this.idempotencyKey,
  });

  factory CreditConsumption.fromJson(Map<String, dynamic> json) {
    return CreditConsumption(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      delta: json['delta'] as int,
      balanceAfter: json['balance_after'] as int,
      type: json['type'] as String,
      applicationId: json['application_id'] as String?,
      sessionId: json['session_id'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      idempotencyKey: json['idempotency_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'delta': delta,
      'balance_after': balanceAfter,
      'type': type,
      'application_id': applicationId,
      'session_id': sessionId,
      'notes': notes,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'idempotency_key': idempotencyKey,
    };
  }
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
class CreditConsumptionResult {
  final int creditsConsumed;
  final int newBalance;
  final int durationSeconds;
  final String? sessionId;
  final String? notes;

  const CreditConsumptionResult({
    required this.creditsConsumed,
    required this.newBalance,
    required this.durationSeconds,
    this.sessionId,
    this.notes,
  });

  factory CreditConsumptionResult.fromJson(Map<String, dynamic> json) {
    return CreditConsumptionResult(
      creditsConsumed: json['credits_consumed'] as int,
      newBalance: json['new_balance'] as int,
      durationSeconds: json['duration_seconds'] as int,
      sessionId: json['session_id'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'credits_consumed': creditsConsumed,
      'new_balance': newBalance,
      'duration_seconds': durationSeconds,
      'session_id': sessionId,
      'notes': notes,
    };
  }
}

/// Session question tracking
class SessionQuestionTracking {
  final String sessionId;
  final int sessionQuestions;
  final int globalTotalQuestions;
  final int questionsPerCredit;
  final int creditsUsed;
  final int questionsRemainingInCurrentCredit;
  final bool shouldDeductCredit;

  const SessionQuestionTracking({
    required this.sessionId,
    required this.sessionQuestions,
    required this.globalTotalQuestions,
    required this.questionsPerCredit,
    required this.creditsUsed,
    required this.questionsRemainingInCurrentCredit,
    required this.shouldDeductCredit,
  });

  factory SessionQuestionTracking.fromJson(Map<String, dynamic> json) {
    return SessionQuestionTracking(
      sessionId: json['session_id'] as String,
      sessionQuestions: json['session_questions'] as int,
      globalTotalQuestions: json['global_total_questions'] as int,
      questionsPerCredit: json['questions_per_credit'] as int,
      creditsUsed: json['credits_used'] as int,
      questionsRemainingInCurrentCredit: json['questions_remaining_in_current_credit'] as int,
      shouldDeductCredit: json['should_deduct_credit'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_questions': sessionQuestions,
      'global_total_questions': globalTotalQuestions,
      'questions_per_credit': questionsPerCredit,
      'credits_used': creditsUsed,
      'questions_remaining_in_current_credit': questionsRemainingInCurrentCredit,
      'should_deduct_credit': shouldDeductCredit,
    };
  }
}

/// Usage analytics
class UsageAnalytics {
  final int periodDays;
  final int totalConsumed;
  final int totalGranted;
  final int netUsage;
  final Map<String, int> breakdownByType;
  final List<CreditConsumption> recentEntries;

  const UsageAnalytics({
    required this.periodDays,
    required this.totalConsumed,
    required this.totalGranted,
    required this.netUsage,
    required this.breakdownByType,
    required this.recentEntries,
  });

  factory UsageAnalytics.fromJson(Map<String, dynamic> json) {
    return UsageAnalytics(
      periodDays: json['period_days'] as int,
      totalConsumed: json['total_consumed'] as int,
      totalGranted: json['total_granted'] as int,
      netUsage: json['net_usage'] as int,
      breakdownByType: Map<String, int>.from(json['breakdown_by_type'] as Map),
      recentEntries: (json['recent_entries'] as List)
          .map((e) => CreditConsumption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_days': periodDays,
      'total_consumed': totalConsumed,
      'total_granted': totalGranted,
      'net_usage': netUsage,
      'breakdown_by_type': breakdownByType,
      'recent_entries': recentEntries.map((e) => e.toJson()).toList(),
    };
  }
}

/// Cost estimation
class CostEstimation {
  final int sizeBytes;
  final int estimatedCost;
  final String currency;
  final String? notes;

  const CostEstimation({
    required this.sizeBytes,
    required this.estimatedCost,
    required this.currency,
    this.notes,
  });

  factory CostEstimation.fromJson(Map<String, dynamic> json) {
    return CostEstimation(
      sizeBytes: json['size_bytes'] as int,
      estimatedCost: json['estimated_cost_credits'] as int,
      currency: json['currency'] as String? ?? 'credits',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size_bytes': sizeBytes,
      'estimated_cost': estimatedCost,
      'currency': currency,
      'notes': notes,
    };
  }
}

/// Credit status check result
class CreditStatusCheck {
  final bool allowed;
  final int currentBalance;
  final String? reason;
  final int? requiredCredits;
  final List<String>? warnings;

  const CreditStatusCheck({
    required this.allowed,
    required this.currentBalance,
    this.reason,
    this.requiredCredits,
    this.warnings,
  });

  factory CreditStatusCheck.fromJson(Map<String, dynamic> json) {
    return CreditStatusCheck(
      allowed: json['allowed'] as bool,
      currentBalance: json['current_balance'] as int,
      reason: json['reason'] as String?,
      requiredCredits: json['required_credits'] as int?,
      warnings: (json['warnings'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowed': allowed,
      'current_balance': currentBalance,
      'reason': reason,
      'required_credits': requiredCredits,
      'warnings': warnings,
    };
  }
}
