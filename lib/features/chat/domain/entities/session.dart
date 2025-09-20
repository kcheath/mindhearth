class Session {
  final String id;
  final String name;
  final String sessionType;
  final String? purpose;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final Map<String, dynamic>? metadata;

  const Session({
    required this.id,
    required this.name,
    required this.sessionType,
    this.purpose,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.metadata,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      name: json['name'] as String,
      sessionType: json['session_type'] as String,
      purpose: json['purpose'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'session_type': sessionType,
      'purpose': purpose,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived,
      'metadata': metadata,
    };
  }

  Session copyWith({
    String? id,
    String? name,
    String? sessionType,
    String? purpose,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      sessionType: sessionType ?? this.sessionType,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Session(id: $id, name: $name, sessionType: $sessionType)';
  }
}
