import 'package:mindhearth/core/models/onboarding_data.dart';

class MockOnboardingData {
  static OnboardingData getSampleData() {
    return OnboardingData(
      currentSituations: [
        CurrentSituation(
          id: 'stress_anxiety',
          title: 'Stress & Anxiety',
          description: 'I\'m feeling overwhelmed by stress and anxiety in my daily life.',
          tags: ['stress', 'anxiety', 'overwhelm'],
          isSelected: false,
        ),
        CurrentSituation(
          id: 'depression',
          title: 'Depression',
          description: 'I\'m struggling with feelings of sadness and low motivation.',
          tags: ['depression', 'sadness', 'low_mood'],
          isSelected: false,
        ),
        CurrentSituation(
          id: 'relationship_issues',
          title: 'Relationship Issues',
          description: 'I\'m having difficulties in my relationships with others.',
          tags: ['relationships', 'communication', 'conflict'],
          isSelected: false,
        ),
        CurrentSituation(
          id: 'work_pressure',
          title: 'Work Pressure',
          description: 'I\'m feeling stressed and overwhelmed by work demands.',
          tags: ['work', 'pressure', 'burnout'],
          isSelected: false,
        ),
        CurrentSituation(
          id: 'life_transition',
          title: 'Life Transition',
          description: 'I\'m going through a significant life change and need support.',
          tags: ['transition', 'change', 'adaptation'],
          isSelected: false,
        ),
      ],
      redactionProfiles: [
        RedactionProfile(
          id: 'standard',
          name: 'Standard Privacy',
          description: 'Balanced privacy protection for most situations.',
          redactionRules: {
            'personal_names': true,
            'locations': false,
            'dates': false,
            'financial_info': true,
            'medical_info': true,
            'relationships': false,
          },
          isSelected: false,
        ),
        RedactionProfile(
          id: 'high_privacy',
          name: 'High Privacy',
          description: 'Maximum privacy protection for sensitive situations.',
          redactionRules: {
            'personal_names': true,
            'locations': true,
            'dates': true,
            'financial_info': true,
            'medical_info': true,
            'relationships': true,
          },
          isSelected: false,
        ),
        RedactionProfile(
          id: 'minimal',
          name: 'Minimal Privacy',
          description: 'Basic privacy protection for general use.',
          redactionRules: {
            'personal_names': false,
            'locations': false,
            'dates': false,
            'financial_info': true,
            'medical_info': false,
            'relationships': false,
          },
          isSelected: false,
        ),
      ],
      consentForm: ConsentForm(
        id: 'main_consent',
        title: 'Privacy Policy & Terms of Service',
        content: 'By using Mindhearth, you agree to our privacy policy and terms of service. Your data is protected with end-to-end encryption and we are committed to maintaining your privacy.',
        sections: [
          ConsentSection(
            id: 'data_collection',
            title: 'Data Collection',
            content: 'We collect only the data necessary to provide our services. This includes your account information, session data, and preferences. All data is encrypted and stored securely.',
            isRequired: true,
            isAccepted: false,
          ),
          ConsentSection(
            id: 'data_processing',
            title: 'Data Processing',
            content: 'Your data is processed to provide personalized support and improve our services. We use advanced AI to analyze your sessions while maintaining strict privacy controls.',
            isRequired: true,
            isAccepted: false,
          ),
          ConsentSection(
            id: 'data_sharing',
            title: 'Data Sharing',
            content: 'We do not sell or share your personal data with third parties. Data may be shared only with your explicit consent or as required by law.',
            isRequired: true,
            isAccepted: false,
          ),
          ConsentSection(
            id: 'marketing',
            title: 'Marketing Communications',
            content: 'You may receive occasional updates about new features and improvements. You can opt out of these communications at any time.',
            isRequired: false,
            isAccepted: false,
          ),
        ],
        isAccepted: false,
      ),
    );
  }
}
