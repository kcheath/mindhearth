import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';

class OnboardingStepConsent extends ConsumerStatefulWidget {
  final Function(VoidCallback) onSave;

  const OnboardingStepConsent({
    super.key,
    required this.onSave,
  });

  @override
  ConsumerState<OnboardingStepConsent> createState() => _OnboardingStepConsentState();
}

class _OnboardingStepConsentState extends ConsumerState<OnboardingStepConsent> {
  Map<String, bool> _sectionConsents = {};
  bool _allRequiredAccepted = false;

  @override
  void initState() {
    super.initState();
    // Register the save callback with the parent
    widget.onSave(_saveConsent);
  }

  void _saveConsent() {
    if (_allRequiredAccepted) {
      final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
      appStateNotifier.setConsentForm(true);
    }
  }

  void _updateSectionConsent(String sectionId, bool accepted) {
    setState(() {
      _sectionConsents[sectionId] = accepted;
      _updateOverallConsent();
    });
  }

  void _updateOverallConsent() {
    final appState = ref.read(appStateProvider);
    final onboardingData = appState.onboardingData;
    
    if (onboardingData != null) {
      final requiredSections = onboardingData.consentForm.sections
          .where((section) => section.isRequired)
          .toList();
      
      _allRequiredAccepted = requiredSections.every((section) => 
          _sectionConsents[section.id] == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final onboardingData = appState.onboardingData;

    if (onboardingData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load onboarding data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final consentForm = onboardingData.consentForm;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        Icon(
          Icons.description,
          size: 80,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 24),
        Text(
          'Consent & Privacy Agreement',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Please review and accept our privacy policy and terms of service to continue.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Consent form content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main consent form
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consentForm.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          consentForm.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Individual consent sections
                Text(
                  'Consent Sections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                ...consentForm.sections.map((section) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  section.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              if (section.isRequired)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Required',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            section.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _sectionConsents[section.id] ?? false,
                                onChanged: (value) {
                                  _updateSectionConsent(section.id, value ?? false);
                                },
                                activeColor: Color(0xFF6750A4),
                              ),
                              Expanded(
                                child: Text(
                                  'I accept this section',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Overall consent checkbox
                SizedBox(height: 24),
                Card(
                  elevation: 2,
                  color: _allRequiredAccepted ? Colors.green[50] : Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _allRequiredAccepted ? Colors.green[200]! : Colors.orange[200]!,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _allRequiredAccepted ? Icons.check_circle : Icons.warning,
                          color: _allRequiredAccepted ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _allRequiredAccepted 
                                ? 'All required consents have been accepted'
                                : 'Please accept all required consent sections to continue',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _allRequiredAccepted ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
