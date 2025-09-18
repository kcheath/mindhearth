
/// Billing status model for comprehensive credit status information
/// Provides trauma-informed status indicators and user guidance
class BillingStatus {
  final String status; // healthy, low_balance, insufficient
  final int currentBalance;
  final int? monthlyGrant;
  final int? daysUntilGrant;
  final List<String> warnings;
  final List<String> actionsRequired;
  final Map<String, dynamic>? metadata;

  const BillingStatus({
    required this.status,
    required this.currentBalance,
    this.monthlyGrant,
    this.daysUntilGrant,
    required this.warnings,
    required this.actionsRequired,
    this.metadata,
  });

  factory BillingStatus.fromJson(Map<String, dynamic> json) {
    return BillingStatus(
      status: json['status'] as String,
      currentBalance: json['current_balance'] as int,
      monthlyGrant: json['monthly_grant'] as int?,
      daysUntilGrant: json['days_until_grant'] as int?,
      warnings: List<String>.from(json['warnings'] ?? []),
      actionsRequired: List<String>.from(json['actions_required'] ?? []),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'current_balance': currentBalance,
      'monthly_grant': monthlyGrant,
      'days_until_grant': daysUntilGrant,
      'warnings': warnings,
      'actions_required': actionsRequired,
      'metadata': metadata,
    };
  }

  /// Check if status is healthy
  bool get isHealthy => status == 'healthy';

  /// Check if balance is low
  bool get isLowBalance => status == 'low_balance';

  /// Check if balance is insufficient
  bool get isInsufficient => status == 'insufficient';

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'healthy':
        return 'Healthy';
      case 'low_balance':
        return 'Low Balance';
      case 'insufficient':
        return 'Insufficient Credits';
      default:
        return status.toUpperCase();
    }
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case 'healthy':
        return 'green';
      case 'low_balance':
        return 'orange';
      case 'insufficient':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Get status icon for UI
  String get statusIcon {
    switch (status) {
      case 'healthy':
        return 'check_circle';
      case 'low_balance':
        return 'warning';
      case 'insufficient':
        return 'error';
      default:
        return 'help';
    }
  }

  /// Check if user has warnings
  bool get hasWarnings => warnings.isNotEmpty;

  /// Check if user has required actions
  bool get hasRequiredActions => actionsRequired.isNotEmpty;

  /// Get formatted grant information
  String get grantInfo {
    if (daysUntilGrant == null) {
      return 'Grant information not available';
    } else if (daysUntilGrant == 0) {
      return 'Grant available today';
    } else if (daysUntilGrant == 1) {
      return 'Grant available tomorrow';
    } else {
      return 'Next grant in $daysUntilGrant days';
    }
  }

  /// Get trauma-informed status message
  String get traumaInformedMessage {
    switch (status) {
      case 'healthy':
        return 'Your account is in good standing. You have sufficient credits to continue using Mindhearth safely.';
      case 'low_balance':
        return 'Your credit balance is getting low. Consider purchasing additional credits to ensure uninterrupted access to your healing journey.';
      case 'insufficient':
        return 'You don\'t have enough credits to continue. This is completely normal - healing takes time and resources. You can purchase credits or wait for your monthly grant.';
      default:
        return 'We\'re here to support you. Please contact support if you have any questions about your account.';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingStatus &&
        other.status == status &&
        other.currentBalance == currentBalance &&
        other.monthlyGrant == monthlyGrant &&
        other.daysUntilGrant == daysUntilGrant &&
        other.warnings == warnings &&
        other.actionsRequired == actionsRequired;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        currentBalance.hashCode ^
        monthlyGrant.hashCode ^
        daysUntilGrant.hashCode ^
        warnings.hashCode ^
        actionsRequired.hashCode;
  }

  @override
  String toString() {
    return 'BillingStatus(status: $status, currentBalance: $currentBalance, monthlyGrant: $monthlyGrant, daysUntilGrant: $daysUntilGrant)';
  }
}
