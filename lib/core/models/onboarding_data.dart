class SituationData {
  final String? age;
  final String? state;
  final String? children;
  final String? background;

  const SituationData({
    this.age,
    this.state,
    this.children,
    this.background,
  });

  factory SituationData.fromJson(Map<String, dynamic> json) {
    return SituationData(
      age: json['age'] as String?,
      state: json['state'] as String?,
      children: json['children'] as String?,
      background: json['background'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'state': state,
      'children': children,
      'background': background,
    };
  }

  SituationData copyWith({
    String? age,
    String? state,
    String? children,
    String? background,
  }) {
    return SituationData(
      age: age ?? this.age,
      state: state ?? this.state,
      children: children ?? this.children,
      background: background ?? this.background,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SituationData &&
        other.age == age &&
        other.state == state &&
        other.children == children &&
        other.background == background;
  }

  @override
  int get hashCode {
    return Object.hash(age, state, children, background);
  }
}

class RedactionProfile {
  final String? userNames;
  final String? childNames;
  final String? emails;
  final String? phoneNumbers;
  final String? address;
  final String? peopleToRedact;
  final bool redactPronouns;

  const RedactionProfile({
    this.userNames,
    this.childNames,
    this.emails,
    this.phoneNumbers,
    this.address,
    this.peopleToRedact,
    this.redactPronouns = false,
  });

  factory RedactionProfile.fromJson(Map<String, dynamic> json) {
    return RedactionProfile(
      userNames: json['user_names'] as String?,
      childNames: json['child_names'] as String?,
      emails: json['emails'] as String?,
      phoneNumbers: json['phone_numbers'] as String?,
      address: json['address'] as String?,
      peopleToRedact: json['people_to_redact'] as String?,
      redactPronouns: json['redact_pronouns'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_names': userNames,
      'child_names': childNames,
      'emails': emails,
      'phone_numbers': phoneNumbers,
      'address': address,
      'people_to_redact': peopleToRedact,
      'redact_pronouns': redactPronouns,
    };
  }

  RedactionProfile copyWith({
    String? userNames,
    String? childNames,
    String? emails,
    String? phoneNumbers,
    String? address,
    String? peopleToRedact,
    bool? redactPronouns,
  }) {
    return RedactionProfile(
      userNames: userNames ?? this.userNames,
      childNames: childNames ?? this.childNames,
      emails: emails ?? this.emails,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      address: address ?? this.address,
      peopleToRedact: peopleToRedact ?? this.peopleToRedact,
      redactPronouns: redactPronouns ?? this.redactPronouns,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RedactionProfile &&
        other.userNames == userNames &&
        other.childNames == childNames &&
        other.emails == emails &&
        other.phoneNumbers == phoneNumbers &&
        other.address == address &&
        other.peopleToRedact == peopleToRedact &&
        other.redactPronouns == redactPronouns;
  }

  @override
  int get hashCode {
    return Object.hash(
      userNames,
      childNames,
      emails,
      phoneNumbers,
      address,
      peopleToRedact,
      redactPronouns,
    );
  }
}



class ConsentData {
  final bool analysisConsent;

  const ConsentData({
    this.analysisConsent = false,
  });

  factory ConsentData.fromJson(Map<String, dynamic> json) {
    return ConsentData(
      analysisConsent: json['analysis_consent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis_consent': analysisConsent,
    };
  }

  ConsentData copyWith({
    bool? analysisConsent,
  }) {
    return ConsentData(
      analysisConsent: analysisConsent ?? this.analysisConsent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsentData &&
        other.analysisConsent == analysisConsent;
  }

  @override
  int get hashCode {
    return analysisConsent.hashCode;
  }
}

class OnboardingData {
  final SituationData? situationData;
  final RedactionProfile? redactionProfile;
  final ConsentData? consentData;

  const OnboardingData({
    this.situationData,
    this.redactionProfile,
    this.consentData,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      situationData: json['relationship_context'] != null 
          ? SituationData.fromJson(json['relationship_context'] as Map<String, dynamic>)
          : null,
      redactionProfile: json['redaction_profile'] != null
          ? RedactionProfile.fromJson(json['redaction_profile'] as Map<String, dynamic>)
          : null,
      consentData: json['llm_training_consent'] != null
          ? ConsentData(analysisConsent: json['llm_training_consent'] as bool)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relationship_context': situationData?.toJson(),
      'redaction_profile': redactionProfile?.toJson(),
      'llm_training_consent': consentData?.analysisConsent,
    };
  }

  OnboardingData copyWith({
    SituationData? situationData,
    RedactionProfile? redactionProfile,
    ConsentData? consentData,
  }) {
    return OnboardingData(
      situationData: situationData ?? this.situationData,
      redactionProfile: redactionProfile ?? this.redactionProfile,
      consentData: consentData ?? this.consentData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingData &&
        other.situationData == situationData &&
        other.redactionProfile == redactionProfile &&
        other.consentData == consentData;
  }

  @override
  int get hashCode {
    return Object.hash(situationData, redactionProfile, consentData);
  }
}
