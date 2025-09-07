import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/onboarding_provider.dart';
import 'package:mindhearth/core/models/onboarding_state.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_welcome.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_privacy.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_passphrase.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_safety_code.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_current_situation.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_redaction_profile.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_consent.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_complete.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  VoidCallback? _savePassphraseCallback;
  VoidCallback? _saveSafetyCodesCallback;
  VoidCallback? _saveCurrentSituationCallback;
  VoidCallback? _saveRedactionProfileCallback;
  VoidCallback? _saveConsentCallback;

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Mindhearth'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (onboardingState.currentStep + 1) / 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                ),
                SizedBox(height: 16),
                Text(
                  'Step ${onboardingState.currentStep + 1} of 8',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Error display
          if (onboardingState.error != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                onboardingState.error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          
          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildStepContent(onboardingState.currentStep, onboardingNotifier),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onboardingState.currentStep > 0)
                  ElevatedButton(
                    onPressed: () => onboardingNotifier.previousStep(),
                    child: Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: () => _handleNextStep(onboardingState, onboardingNotifier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    onboardingState.currentStep == 7 ? 'Complete' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step, OnboardingNotifier onboardingNotifier) {
    switch (step) {
      case 0:
        return OnboardingStepWelcome();
      case 1:
        return OnboardingStepPrivacy();
      case 2:
        return OnboardingStepPassphrase(
          onSave: (callback) => _savePassphraseCallback = callback,
        );
      case 3:
        return OnboardingStepSafetyCode(
          onSave: (callback) => _saveSafetyCodesCallback = callback,
        );
      case 4:
        return OnboardingStepCurrentSituation(
          onSave: (callback) => _saveCurrentSituationCallback = callback,
        );
      case 5:
        return OnboardingStepRedactionProfile(
          onSave: (callback) => _saveRedactionProfileCallback = callback,
        );
      case 6:
        return OnboardingStepConsent(
          onSave: (callback) => _saveConsentCallback = callback,
        );
      case 7:
        return OnboardingStepComplete();
      default:
        return OnboardingStepWelcome();
    }
  }

  void _handleNextStep(OnboardingState state, OnboardingNotifier onboardingNotifier) {
    if (state.currentStep == 2) {
      // On passphrase step, save passphrase before proceeding
      _savePassphraseCallback?.call();
      onboardingNotifier.nextStep();
    } else if (state.currentStep == 3) {
      // On safety code step, save safety codes before proceeding
      _saveSafetyCodesCallback?.call();
      onboardingNotifier.nextStep();
    } else if (state.currentStep == 4) {
      // On current situation step, save selection before proceeding
      _saveCurrentSituationCallback?.call();
      onboardingNotifier.nextStep();
    } else if (state.currentStep == 5) {
      // On redaction profile step, save selection before proceeding
      _saveRedactionProfileCallback?.call();
      onboardingNotifier.nextStep();
    } else if (state.currentStep == 6) {
      // On consent step, save consent before proceeding
      _saveConsentCallback?.call();
      onboardingNotifier.nextStep();
    } else if (state.currentStep == 7) {
      // Complete onboarding
      onboardingNotifier.completeOnboarding();
    } else {
      onboardingNotifier.nextStep();
    }
  }
}
