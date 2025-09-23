import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/onboarding_provider.dart';
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
    final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
    onboardingNotifier.saveConsentForm(_analysisConsent);
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final onboardingData = onboardingState.onboardingData;

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
        // Header with information from the card
        Image.asset(
          'assets/images/mindhearth_logo.png',
          width: 80,
          height: 80,
        ),
        SizedBox(height: 24),
        Text(
          'Help Improve Mental Health AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Your redacted conversations help us train our AI to better understand mental health challenges and provide more empathetic support.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          '• All personal information is automatically removed\n• Only emotional content and insights remain\n• You can change this setting anytime\n• Your privacy and security are our top priority',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Consent switch
        SwitchListTile(
          title: Text(
            'Allow AI training with my redacted conversations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'This helps improve mental health support for everyone',
            style: TextStyle(fontSize: 14),
          ),
          value: _analysisConsent,
          onChanged: (value) {
            setState(() {
              _analysisConsent = value;
            });
          },
          activeColor: Color(0xFF6750A4),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
