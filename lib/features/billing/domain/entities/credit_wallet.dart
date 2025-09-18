import 'dart:convert';

/// Credit wallet model representing a user's credit balance
/// Aligned with Mindhearth's principles of transparency and user empowerment
class CreditWallet {
  final String userId;
  final int balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditWallet({
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreditWallet.fromJson(Map<String, dynamic> json) {
    return CreditWallet(
      userId: json['user_id'] as String,
      balance: json['balance'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CreditWallet copyWith({
    String? userId,
    int? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditWallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditWallet &&
        other.userId == userId &&
        other.balance == balance &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        balance.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'CreditWallet(userId: $userId, balance: $balance, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
