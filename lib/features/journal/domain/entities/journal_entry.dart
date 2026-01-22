class JournalEntry {
  final String id;
  final String? sessionId;
  final String applicationId;
  final String originalContent;
  final String? redactedContent;
  final String? header;
  final String? entryType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metaData;
  final bool consent;
  final List<String>? tags;

  JournalEntry({
    required this.id,
    this.sessionId,
    required this.applicationId,
    required this.originalContent,
    this.redactedContent,
    this.header,
    this.entryType,
    required this.createdAt,
    required this.updatedAt,
    this.metaData,
    required this.consent,
    this.tags,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      sessionId: json['session_id'],
      applicationId: json['application_id'],
      originalContent: json['original_content'],
      redactedContent: json['redacted_content'],
      header: json['header'],
      entryType: json['entry_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      metaData: json['meta_data'],
      consent: json['consent'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'application_id': applicationId,
      'original_content': originalContent,
      'redacted_content': redactedContent,
      'header': header,
      'entry_type': entryType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'meta_data': metaData,
      'consent': consent,
      'tags': tags,
    };
  }
}

class JournalEntryCreate {
  final String originalContent;
  final String? redactedContent;
  final String? entryType;
  final String? sessionId;
  final String? header;
  final List<String>? tags;
  final bool consent;

  JournalEntryCreate({
    required this.originalContent,
    this.redactedContent,
    this.entryType,
    this.sessionId,
    this.header,
    this.tags,
    this.consent = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_content': originalContent,
      'redacted_content': redactedContent,
      'entry_type': entryType,
      'session_id': sessionId,
      'header': header,
      'tags': tags,
      'consent': consent,
    };
  }
}

class AIJournalSummaryRequest {
  final String sessionId;
  final String? entryType;
  final List<String>? tags;

  AIJournalSummaryRequest({
    required this.sessionId,
    this.entryType,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'entry_type': entryType,
      'tags': tags,
    };
  }
}

class AIJournalSummaryResponse {
  final String id;
  final String aiSummary;
  final DateTime createdAt;

  AIJournalSummaryResponse({
    required this.id,
    required this.aiSummary,
    required this.createdAt,
  });

  factory AIJournalSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AIJournalSummaryResponse(
      id: json['id'] as String,
      aiSummary: json['ai_summary'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ai_summary': aiSummary,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class JournalEntriesResponse {
  final List<JournalEntry> journalEntries;
  final int total;

  JournalEntriesResponse({
    required this.journalEntries,
    required this.total,
  });

  factory JournalEntriesResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response formats safely
    List<dynamic> entriesList = [];
    int total = 0;
    
    if (json['journal_entries'] is List) {
      entriesList = json['journal_entries'] as List;
    } else if (json['journal_entries'] == null) {
      entriesList = [];
    }
    
    total = json['total'] ?? entriesList.length;
    
    return JournalEntriesResponse(
      journalEntries: entriesList
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: total,
    );
  }
}
