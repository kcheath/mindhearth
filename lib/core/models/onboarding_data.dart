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
    // Extract user's selected values from user data
    final selectedSituationId = json['current_situation_id'] as String?;
    final selectedRedactionProfileId = json['redaction_profile_id'] as String?;
    final consentAccepted = json['consent_accepted'] as bool?;
    
    // Create static onboarding options (these would normally come from backend)
    final currentSituations = [
      CurrentSituation(
        id: 'situation_1',
        title: 'General Mental Health Support',
        description: 'I\'m looking for general mental health support and guidance.',
        tags: ['general', 'support'],
        isSelected: selectedSituationId == 'situation_1',
      ),
      CurrentSituation(
        id: 'situation_2',
        title: 'Anxiety & Stress Management',
        description: 'I\'m dealing with anxiety, stress, or overwhelming emotions.',
        tags: ['anxiety', 'stress'],
        isSelected: selectedSituationId == 'situation_2',
      ),
      CurrentSituation(
        id: 'situation_3',
        title: 'Depression Support',
        description: 'I\'m experiencing symptoms of depression or low mood.',
        tags: ['depression', 'mood'],
        isSelected: selectedSituationId == 'situation_3',
      ),
      CurrentSituation(
        id: 'situation_4',
        title: 'Crisis Support',
        description: 'I\'m in crisis and need immediate support.',
        tags: ['crisis', 'emergency'],
        isSelected: selectedSituationId == 'situation_4',
      ),
    ];
    
    final redactionProfiles = [
      RedactionProfile(
        id: 'profile_1',
        name: 'Standard Privacy',
        description: 'Standard privacy settings with basic content filtering.',
        redactionRules: {
          'personal_info': true,
          'locations': true,
          'dates': false,
          'context': false,
        },
        isSelected: selectedRedactionProfileId == 'profile_1',
      ),
      RedactionProfile(
        id: 'profile_2',
        name: 'Enhanced Privacy',
        description: 'Enhanced privacy with stricter content filtering.',
        redactionRules: {
          'personal_info': true,
          'locations': true,
          'dates': true,
          'context': false,
        },
        isSelected: selectedRedactionProfileId == 'profile_2',
      ),
      RedactionProfile(
        id: 'profile_3',
        name: 'Maximum Privacy',
        description: 'Maximum privacy with comprehensive content filtering.',
        redactionRules: {
          'personal_info': true,
          'locations': true,
          'dates': true,
          'context': true,
        },
        isSelected: selectedRedactionProfileId == 'profile_3',
      ),
    ];
    
    final consentForm = ConsentForm(
      id: 'privacy_consent',
      title: 'Privacy & Data Consent',
      content: 'Please review and accept our privacy policy and data handling practices.',
      sections: [
        ConsentSection(
          id: 'privacy_policy',
          title: 'Privacy Policy',
          content: 'We are committed to protecting your privacy. Your data is encrypted and stored securely.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'data_usage',
          title: 'Data Usage',
          content: 'Your data is used solely to provide mental health support and improve our services.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'third_party',
          title: 'Third-Party Services',
          content: 'We may use third-party services for analytics and support, all with appropriate safeguards.',
          isRequired: false,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'emergency_contact',
          title: 'Emergency Contact',
          content: 'In case of emergency, we may contact emergency services if necessary.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
      ],
      isAccepted: consentAccepted == true,
    );
    
    return OnboardingData(
      currentSituations: currentSituations,
      redactionProfiles: redactionProfiles,
      consentForm: consentForm,
      selectedSituationId: selectedSituationId,
      selectedRedactionProfileId: selectedRedactionProfileId,
      consentAccepted: consentAccepted,
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
