/// Journal state management
class JournalState {
  final List<JournalEntry> entries;
  final JournalEntry? currentEntry;
  final bool isLoading;
  final String? error;

  const JournalState({
    this.entries = const [],
    this.currentEntry,
    this.isLoading = false,
    this.error,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    JournalEntry? currentEntry,
    bool? isLoading,
    String? error,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      currentEntry: currentEntry ?? this.currentEntry,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Load journal entries
  JournalState loadEntries(List<JournalEntry> entries) {
    return copyWith(
      entries: entries,
      error: null,
      isLoading: false,
    );
  }

  /// Add new journal entry
  JournalState addEntry(JournalEntry entry) {
    return copyWith(
      entries: [entry, ...entries],
      isLoading: false,
    );
  }

  /// Update existing journal entry
  JournalState updateEntry(JournalEntry entry) {
    final updatedEntries = entries.map((e) => e.id == entry.id ? entry : e).toList();
    return copyWith(entries: updatedEntries, isLoading: false);
  }

  /// Delete journal entry
  JournalState deleteEntry(String entryId) {
    final updatedEntries = entries.where((e) => e.id != entryId).toList();
    return copyWith(entries: updatedEntries, isLoading: false);
  }

  /// Set current entry
  JournalState setCurrentEntry(JournalEntry entry) {
    return copyWith(currentEntry: entry);
  }

  /// Clear current entry
  JournalState clearCurrentEntry() {
    return copyWith(currentEntry: null);
  }

  /// Set loading state
  JournalState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set error state
  JournalState setError(String error) {
    return copyWith(error: error, isLoading: false);
  }

  /// Clear error state
  JournalState clearError() {
    return copyWith(error: null);
  }

  /// Get entry by ID
  JournalEntry? getEntryById(String id) {
    try {
      return entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get entries by type
  List<JournalEntry> getEntriesByType(String type) {
    return entries.where((entry) => entry.entryType == type).toList();
  }

  /// Check if entries are loaded
  bool get hasEntries => entries.isNotEmpty;

  /// Get entry count
  int get entryCount => entries.length;

  /// Get recent entries (last 10)
  List<JournalEntry> get recentEntries => entries.take(10).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalState &&
        other.entries == entries &&
        other.currentEntry == currentEntry &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      entries,
      currentEntry,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'JournalState('
        'entries: ${entries.length} items, '
        'currentEntry: ${currentEntry?.id}, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}

/// Journal entry model
class JournalEntry {
  final String id;
  final String header;
  final String entryType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sessionId;
  final String? originalContent;
  final String? redactedContent;
  final Map<String, dynamic>? metaData;
  final bool consent;
  final List<String> keywords;
  final String? sentiment;
  final bool isAIGenerated;

  const JournalEntry({
    required this.id,
    required this.header,
    required this.entryType,
    required this.createdAt,
    this.updatedAt,
    this.sessionId,
    this.originalContent,
    this.redactedContent,
    this.metaData,
    this.consent = false,
    this.keywords = const [],
    this.sentiment,
    this.isAIGenerated = false,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    // Extract keywords from metadata
    List<String> keywords = [];
    String? sentiment;
    bool isAIGenerated = false;
    
    final metaData = json['meta_data'] as Map<String, dynamic>?;
    if (metaData != null) {
      keywords = (metaData['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      sentiment = metaData['sentiment'] as String?;
      isAIGenerated = metaData['ai_generated'] as bool? ?? false;
    }
    
    return JournalEntry(
      id: json['id'] as String,
      header: json['header'] as String,
      entryType: json['entry_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      sessionId: json['session_id'] as String?,
      originalContent: json['original_content'] as String?,
      redactedContent: json['redacted_content'] as String?,
      metaData: metaData,
      consent: json['consent'] as bool? ?? false,
      keywords: keywords,
      sentiment: sentiment,
      isAIGenerated: isAIGenerated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'header': header,
      'entry_type': entryType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'session_id': sessionId,
      'original_content': originalContent,
      'redacted_content': redactedContent,
      'meta_data': {
        ...?metaData,
        'tags': keywords,
        'sentiment': sentiment,
        'ai_generated': isAIGenerated,
      },
      'consent': consent,
    };
  }

  JournalEntry copyWith({
    String? id,
    String? header,
    String? entryType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sessionId,
    String? originalContent,
    String? redactedContent,
    Map<String, dynamic>? metaData,
    bool? consent,
    List<String>? keywords,
    String? sentiment,
    bool? isAIGenerated,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      header: header ?? this.header,
      entryType: entryType ?? this.entryType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      originalContent: originalContent ?? this.originalContent,
      redactedContent: redactedContent ?? this.redactedContent,
      metaData: metaData ?? this.metaData,
      consent: consent ?? this.consent,
      keywords: keywords ?? this.keywords,
      sentiment: sentiment ?? this.sentiment,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
    );
  }

  /// Check if entry is recent (within last 7 days)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7;
  }

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry &&
        other.id == id &&
        other.header == header &&
        other.entryType == entryType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.sessionId == sessionId &&
        other.originalContent == originalContent &&
        other.redactedContent == redactedContent &&
        other.metaData == metaData &&
        other.consent == consent &&
        other.keywords == keywords &&
        other.sentiment == sentiment &&
        other.isAIGenerated == isAIGenerated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      header,
      entryType,
      createdAt,
      updatedAt,
      sessionId,
      originalContent,
      redactedContent,
      metaData,
      consent,
      keywords,
      sentiment,
      isAIGenerated,
    );
  }

  @override
  String toString() {
    return 'JournalEntry('
        'id: $id, '
        'header: $header, '
        'entryType: $entryType, '
        'createdAt: $createdAt, '
        'sessionId: $sessionId, '
        'consent: $consent'
        ')';
  }
}
