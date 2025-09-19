/// Credit package model for purchase options
/// Provides trauma-informed pricing and clear value propositions
class CreditPackage {
  final String id;
  final String name;
  final String description;
  final int credits;
  final double price;
  final String currency;
  final bool isPopular;
  final String? bonusDescription;
  final int? bonusCredits;
  final Map<String, dynamic>? metadata;

  const CreditPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.price,
    required this.currency,
    this.isPopular = false,
    this.bonusDescription,
    this.bonusCredits,
    this.metadata,
  });

  factory CreditPackage.fromJson(Map<String, dynamic> json) {
    return CreditPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      credits: json['credits'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      isPopular: json['is_popular'] as bool? ?? false,
      bonusDescription: json['bonus_description'] as String?,
      bonusCredits: json['bonus_credits'] as int?,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'credits': credits,
      'price': price,
      'currency': currency,
      'is_popular': isPopular,
      'bonus_description': bonusDescription,
      'bonus_credits': bonusCredits,
      'metadata': metadata,
    };
  }

  /// Get total credits including bonus
  int get totalCredits => credits + (bonusCredits ?? 0);

  /// Get price per credit
  double get pricePerCredit => price / totalCredits;

  /// Get formatted price string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Get formatted credits string
  String get formattedCredits => '$totalCredits credits';

  /// Get value proposition text
  String get valueProposition {
    if (bonusCredits != null && bonusCredits! > 0) {
      return '$credits + $bonusCredits bonus credits';
    }
    return '$credits credits';
  }
}
