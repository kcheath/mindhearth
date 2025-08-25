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
    
    // Create static onboarding options with specific mental health situations
    final currentSituations = [
      CurrentSituation(
        id: 'situation_1',
        title: 'I\'m feeling overwhelmed and need someone to talk to',
        description: 'I\'m dealing with daily stress, work pressure, or life challenges that feel overwhelming. I need a safe space to process my thoughts and feelings.',
        tags: ['stress', 'overwhelmed', 'daily-life'],
        isSelected: selectedSituationId == 'situation_1',
      ),
      CurrentSituation(
        id: 'situation_2',
        title: 'I\'m struggling with anxiety or panic attacks',
        description: 'I experience anxiety, worry, or panic attacks that interfere with my daily life. I need help managing these symptoms and finding coping strategies.',
        tags: ['anxiety', 'panic', 'coping'],
        isSelected: selectedSituationId == 'situation_2',
      ),
      CurrentSituation(
        id: 'situation_3',
        title: 'I\'m feeling depressed or hopeless',
        description: 'I\'m experiencing persistent sadness, low mood, or feelings of hopelessness. I need support to work through these difficult emotions.',
        tags: ['depression', 'sadness', 'hopelessness'],
        isSelected: selectedSituationId == 'situation_3',
      ),
      CurrentSituation(
        id: 'situation_4',
        title: 'I\'m dealing with trauma or past experiences',
        description: 'I have experienced trauma or difficult past experiences that continue to affect me. I need a safe environment to process and heal.',
        tags: ['trauma', 'healing', 'past-experiences'],
        isSelected: selectedSituationId == 'situation_4',
      ),
      CurrentSituation(
        id: 'situation_5',
        title: 'I\'m in crisis and need immediate support',
        description: 'I\'m experiencing a mental health crisis and need immediate support. I may be having thoughts of self-harm or feeling completely overwhelmed.',
        tags: ['crisis', 'emergency', 'immediate-support'],
        isSelected: selectedSituationId == 'situation_5',
      ),
      CurrentSituation(
        id: 'situation_6',
        title: 'I want to improve my overall mental wellness',
        description: 'I\'m generally doing okay but want to improve my mental health, build resilience, and develop better coping skills for life\'s challenges.',
        tags: ['wellness', 'resilience', 'self-improvement'],
        isSelected: selectedSituationId == 'situation_6',
      ),
    ];
    
    final redactionProfiles = [
      RedactionProfile(
        id: 'profile_1',
        name: 'Essential Privacy',
        description: 'Removes only the most sensitive personal information while preserving the therapeutic value of your conversations.',
        redactionRules: {
          'names': true,
          'addresses': true,
          'phone_numbers': true,
          'email_addresses': true,
          'specific_dates': false,
          'locations': false,
          'workplace': false,
          'family_details': false,
        },
        isSelected: selectedRedactionProfileId == 'profile_1',
      ),
      RedactionProfile(
        id: 'profile_2',
        name: 'Enhanced Privacy',
        description: 'Removes personal identifiers and specific details while maintaining the emotional context of your experiences.',
        redactionRules: {
          'names': true,
          'addresses': true,
          'phone_numbers': true,
          'email_addresses': true,
          'specific_dates': true,
          'locations': true,
          'workplace': true,
          'family_details': false,
        },
        isSelected: selectedRedactionProfileId == 'profile_2',
      ),
      RedactionProfile(
        id: 'profile_3',
        name: 'Maximum Privacy',
        description: 'Removes all personal details and specific references, focusing only on emotional content and therapeutic insights.',
        redactionRules: {
          'names': true,
          'addresses': true,
          'phone_numbers': true,
          'email_addresses': true,
          'specific_dates': true,
          'locations': true,
          'workplace': true,
          'family_details': true,
        },
        isSelected: selectedRedactionProfileId == 'profile_3',
      ),
    ];
    
    final consentForm = ConsentForm(
      id: 'llm_training_consent',
      title: 'AI Training Consent',
      content: 'To provide you with better mental health support, we may use your redacted conversations to improve our AI assistant. Your privacy and safety are our top priorities.',
      sections: [
        ConsentSection(
          id: 'data_redaction',
          title: 'Data Redaction & Privacy',
          content: 'Before any data is used for AI training, all personal information (names, addresses, specific dates, etc.) will be automatically removed according to your privacy settings. Only the emotional content and therapeutic insights remain.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'purpose_improvement',
          title: 'Purpose: Improving Mental Health AI',
          content: 'Your redacted conversations help us train our AI to better understand mental health challenges, provide more empathetic responses, and offer more effective support to you and others seeking help.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'voluntary_participation',
          title: 'Voluntary Participation',
          content: 'This is completely voluntary. You can change your mind at any time in your settings. Choosing not to participate will not affect the quality of support you receive.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'data_security',
          title: 'Data Security & Control',
          content: 'All data is encrypted, stored securely, and used only for AI training purposes. You maintain full control and can request deletion of your data at any time.',
          isRequired: true,
          isAccepted: consentAccepted == true,
        ),
        ConsentSection(
          id: 'research_benefits',
          title: 'Research Benefits (Optional)',
          content: 'Your redacted data may also contribute to mental health research to improve support systems and help others facing similar challenges. This is completely optional.',
          isRequired: false,
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
