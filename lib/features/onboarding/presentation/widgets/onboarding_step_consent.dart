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
  bool _analysisConsent = true; // Default to true as per Tsukiyo

  @override
  void initState() {
    super.initState();
    // Register the save callback with the parent
    widget.onSave(_saveConsent);
  }

  void _saveConsent() {
    final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
    appStateNotifier.setConsentForm(_analysisConsent);
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



    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        Icon(
          Icons.psychology,
          size: 80,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 24),
        Text(
          'AI Training Consent',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Consent form content
        Expanded(
          child: Column(
            children: [
              Flexible(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 32,
                          color: Color(0xFF6750A4),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Help Improve Mental Health AI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Your redacted conversations help us train our AI to better understand mental health challenges and provide more empathetic support.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• All personal information is automatically removed\n• Only emotional content and insights remain\n• You can change this setting anytime\n• Your privacy and security are our top priority',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SwitchListTile(
                title: Text(
                  'Allow AI training with my redacted conversations',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'This helps improve mental health support for everyone',
                  style: TextStyle(fontSize: 12),
                ),
                value: _analysisConsent,
                onChanged: (value) {
                  setState(() {
                    _analysisConsent = value;
                  });
                },
                activeColor: Color(0xFF6750A4),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
