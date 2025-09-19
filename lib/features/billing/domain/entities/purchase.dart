
/// Purchase model for tracking in-app purchase transactions
/// Ensures secure and transparent purchase handling in Mindhearth
class Purchase {
  final String id;
  final String userId;
  final String provider; // apple, google, stripe, paypal
  final String productId;
  final int quantity;
  final int amountCents;
  final String currency;
  final String transactionId;
  final String status; // completed, pending, failed, refunded
  final String? receiptData;
  final Map<String, dynamic>? metadata;
  final DateTime validatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ledgerEntryId;

  const Purchase({
    required this.id,
    required this.userId,
    required this.provider,
    required this.productId,
    required this.quantity,
    required this.amountCents,
    required this.currency,
    required this.transactionId,
    required this.status,
    this.receiptData,
    this.metadata,
    required this.validatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.ledgerEntryId,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      provider: json['provider'] as String? ?? 'unknown',
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      amountCents: json['amount_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      transactionId: json['transaction_id'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      receiptData: json['receipt_data'] as String?,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      validatedAt: json['validated_at'] != null 
          ? DateTime.parse(json['validated_at'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      ledgerEntryId: json['ledger_entry_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider,
      'product_id': productId,
      'quantity': quantity,
      'amount_cents': amountCents,
      'currency': currency,
      'transaction_id': transactionId,
      'status': status,
      'receipt_data': receiptData,
      'metadata': metadata,
      'validated_at': validatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ledger_entry_id': ledgerEntryId,
    };
  }

  /// Check if purchase is completed
  bool get isCompleted => status == 'completed';

  /// Check if purchase is pending
  bool get isPending => status == 'pending';

  /// Check if purchase failed
  bool get isFailed => status == 'failed';

  /// Check if purchase was refunded
  bool get isRefunded => status == 'refunded';

  /// Get formatted amount string
  String get formattedAmount {
    final amount = amountCents / 100;
    return '\$${amount.toStringAsFixed(2)} $currency';
  }

  /// Get provider display name
  String get providerDisplayName {
    switch (provider) {
      case 'apple':
        return 'Apple App Store';
      case 'google':
        return 'Google Play Store';
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      default:
        return provider.toUpperCase();
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status.toUpperCase();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Purchase &&
        other.id == id &&
        other.userId == userId &&
        other.provider == provider &&
        other.productId == productId &&
        other.quantity == quantity &&
        other.amountCents == amountCents &&
        other.currency == currency &&
        other.transactionId == transactionId &&
        other.status == status &&
        other.receiptData == receiptData &&
        other.validatedAt == validatedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.ledgerEntryId == ledgerEntryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        provider.hashCode ^
        productId.hashCode ^
        quantity.hashCode ^
        amountCents.hashCode ^
        currency.hashCode ^
        transactionId.hashCode ^
        status.hashCode ^
        receiptData.hashCode ^
        validatedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        ledgerEntryId.hashCode;
  }

  @override
  String toString() {
    return 'Purchase(id: $id, userId: $userId, provider: $provider, productId: $productId, amountCents: $amountCents, status: $status)';
  }
}
