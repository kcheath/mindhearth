class CurrentSituation {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final bool isSelected;

  const CurrentSituation({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.isSelected,
  });

  factory CurrentSituation.fromJson(Map<String, dynamic> json) {
    return CurrentSituation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'is_selected': isSelected,
    };
  }

  CurrentSituation copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    bool? isSelected,
  }) {
    return CurrentSituation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class RedactionProfile {
  final String id;
  final String name;
  final String description;
  final Map<String, bool> redactionRules;
  final bool isSelected;

  const RedactionProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.redactionRules,
    required this.isSelected,
  });

  factory RedactionProfile.fromJson(Map<String, dynamic> json) {
    return RedactionProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      redactionRules: Map<String, bool>.from(json['redaction_rules'] ?? {}),
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'redaction_rules': redactionRules,
      'is_selected': isSelected,
    };
  }

  RedactionProfile copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, bool>? redactionRules,
    bool? isSelected,
  }) {
    return RedactionProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      redactionRules: redactionRules ?? this.redactionRules,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ConsentSection {
  final String id;
  final String title;
  final String content;
  final bool isRequired;
  final bool isAccepted;

  const ConsentSection({
    required this.id,
    required this.title,
    required this.content,
    required this.isRequired,
    required this.isAccepted,
  });

  factory ConsentSection.fromJson(Map<String, dynamic> json) {
    return ConsentSection(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isRequired: json['is_required'] as bool? ?? false,
      isAccepted: json['is_accepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'is_required': isRequired,
      'is_accepted': isAccepted,
    };
  }

  ConsentSection copyWith({
    String? id,
    String? title,
    String? content,
    bool? isRequired,
    bool? isAccepted,
  }) {
    return ConsentSection(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isRequired: isRequired ?? this.isRequired,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}

class ConsentForm {
  final String id;
  final String title;
  final String content;
  final List<ConsentSection> sections;
  final bool isAccepted;

  const ConsentForm({
    required this.id,
    required this.title,
    required this.content,
    required this.sections,
    required this.isAccepted,
  });

  factory ConsentForm.fromJson(Map<String, dynamic> json) {
    return ConsentForm(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      sections: (json['sections'] as List<dynamic>?)
          ?.map((e) => ConsentSection.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      isAccepted: json['is_accepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'sections': sections.map((e) => e.toJson()).toList(),
      'is_accepted': isAccepted,
    };
  }

  ConsentForm copyWith({
    String? id,
    String? title,
    String? content,
    List<ConsentSection>? sections,
    bool? isAccepted,
  }) {
    return ConsentForm(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sections: sections ?? this.sections,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}

class OnboardingData {
  final List<CurrentSituation> currentSituations;
  final List<RedactionProfile> redactionProfiles;
  final ConsentForm consentForm;
  final String? selectedSituationId;
  final String? selectedRedactionProfileId;
  final bool? consentAccepted;

  const OnboardingData({
    required this.currentSituations,
    required this.redactionProfiles,
    required this.consentForm,
    this.selectedSituationId,
    this.selectedRedactionProfileId,
    this.consentAccepted,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      currentSituations: (json['current_situations'] as List<dynamic>?)
          ?.map((e) => CurrentSituation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      redactionProfiles: (json['redaction_profiles'] as List<dynamic>?)
          ?.map((e) => RedactionProfile.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      consentForm: ConsentForm.fromJson(json['consent_form'] as Map<String, dynamic>),
      selectedSituationId: json['selected_situation_id'] as String?,
      selectedRedactionProfileId: json['selected_redaction_profile_id'] as String?,
      consentAccepted: json['consent_accepted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_situations': currentSituations.map((e) => e.toJson()).toList(),
      'redaction_profiles': redactionProfiles.map((e) => e.toJson()).toList(),
      'consent_form': consentForm.toJson(),
      'selected_situation_id': selectedSituationId,
      'selected_redaction_profile_id': selectedRedactionProfileId,
      'consent_accepted': consentAccepted,
    };
  }

  OnboardingData copyWith({
    List<CurrentSituation>? currentSituations,
    List<RedactionProfile>? redactionProfiles,
    ConsentForm? consentForm,
    String? selectedSituationId,
    String? selectedRedactionProfileId,
    bool? consentAccepted,
  }) {
    return OnboardingData(
      currentSituations: currentSituations ?? this.currentSituations,
      redactionProfiles: redactionProfiles ?? this.redactionProfiles,
      consentForm: consentForm ?? this.consentForm,
      selectedSituationId: selectedSituationId ?? this.selectedSituationId,
      selectedRedactionProfileId: selectedRedactionProfileId ?? this.selectedRedactionProfileId,
      consentAccepted: consentAccepted ?? this.consentAccepted,
    );
  }
}
