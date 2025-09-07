/// Chat session state management
class SessionState {
  final List<Session> sessions;
  final Session? currentSession;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.sessions = const [],
    this.currentSession,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<Session>? sessions,
    Session? currentSession,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Load sessions
  SessionState loadSessions(List<Session> sessions) {
    return copyWith(
      sessions: sessions,
      error: null,
      isLoading: false,
    );
  }

  /// Add new session
  SessionState addSession(Session session) {
    return copyWith(
      sessions: [session, ...sessions],
    );
  }

  /// Set current session
  SessionState setCurrentSession(Session session) {
    return copyWith(currentSession: session);
  }

  /// Clear current session
  SessionState clearCurrentSession() {
    return copyWith(currentSession: null);
  }

  /// Set loading state
  SessionState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set error state
  SessionState setError(String error) {
    return copyWith(error: error, isLoading: false);
  }

  /// Clear error state
  SessionState clearError() {
    return copyWith(error: null);
  }

  /// Get session by ID
  Session? getSessionById(String id) {
    try {
      return sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if sessions are loaded
  bool get hasSessions => sessions.isNotEmpty;

  /// Get session count
  int get sessionCount => sessions.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionState &&
        other.sessions == sessions &&
        other.currentSession == currentSession &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      sessions,
      currentSession,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'SessionState('
        'sessions: ${sessions.length} items, '
        'currentSession: ${currentSession?.id}, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}

/// Chat session model
class Session {
  final String id;
  final String name;
  final String sessionType;
  final String? purpose;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int messageCount;

  const Session({
    required this.id,
    required this.name,
    required this.sessionType,
    this.purpose,
    required this.createdAt,
    this.updatedAt,
    this.messageCount = 0,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      name: json['name'] as String,
      sessionType: json['session_type'] as String,
      purpose: json['purpose'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      messageCount: json['message_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'session_type': sessionType,
      'purpose': purpose,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'message_count': messageCount,
    };
  }

  Session copyWith({
    String? id,
    String? name,
    String? sessionType,
    String? purpose,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      sessionType: sessionType ?? this.sessionType,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
        other.id == id &&
        other.name == name &&
        other.sessionType == sessionType &&
        other.purpose == purpose &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.messageCount == messageCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      sessionType,
      purpose,
      createdAt,
      updatedAt,
      messageCount,
    );
  }

  @override
  String toString() {
    return 'Session('
        'id: $id, '
        'name: $name, '
        'sessionType: $sessionType, '
        'purpose: $purpose, '
        'createdAt: $createdAt, '
        'messageCount: $messageCount'
        ')';
  }
}
