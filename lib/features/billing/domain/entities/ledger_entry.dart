import 'dart:convert';

/// Ledger entry model for immutable audit trail of all credit transactions
/// Ensures transparency and accountability in Mindhearth's billing system
class LedgerEntry {
  final String id;
  final String userId;
  final int delta; // Positive for credits added, negative for debits
  final int balanceAfter; // Balance after this transaction
  final String type; // grant, chat_debit, doc_debit, purchase, gift_in, gift_out, adjustment, carry_deduction
  final String? applicationId;
  final String? sessionId;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String? idempotencyKey;

  const LedgerEntry({
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

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      delta: json['delta'] as int,
      balanceAfter: json['balance_after'] as int,
      type: json['type'] as String,
      applicationId: json['application_id'] as String?,
      sessionId: json['session_id'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
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

  /// Check if this is a credit (positive delta)
  bool get isCredit => delta > 0;

  /// Check if this is a debit (negative delta)
  bool get isDebit => delta < 0;

  /// Get formatted delta string with sign
  String get formattedDelta => '${isCredit ? '+' : ''}$delta';

  /// Get human-readable type description
  String get typeDescription {
    switch (type) {
      case 'grant':
        return 'Credit Grant';
      case 'chat_debit':
        return 'Chat Usage';
      case 'doc_debit':
        return 'Document Processing';
      case 'purchase':
        return 'Purchase';
      case 'gift_in':
        return 'Gift Received';
      case 'gift_out':
        return 'Gift Sent';
      case 'adjustment':
        return 'Balance Adjustment';
      case 'carry_deduction':
        return 'Carry Deduction';
      default:
        return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LedgerEntry &&
        other.id == id &&
        other.userId == userId &&
        other.delta == delta &&
        other.balanceAfter == balanceAfter &&
        other.type == type &&
        other.applicationId == applicationId &&
        other.sessionId == sessionId &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.idempotencyKey == idempotencyKey;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        delta.hashCode ^
        balanceAfter.hashCode ^
        type.hashCode ^
        applicationId.hashCode ^
        sessionId.hashCode ^
        notes.hashCode ^
        createdAt.hashCode ^
        idempotencyKey.hashCode;
  }

  @override
  String toString() {
    return 'LedgerEntry(id: $id, userId: $userId, delta: $delta, balanceAfter: $balanceAfter, type: $type, createdAt: $createdAt)';
  }
}
