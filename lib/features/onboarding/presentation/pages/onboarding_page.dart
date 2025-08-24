import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_welcome.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_privacy.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_passphrase.dart';
import 'package:mindhearth/features/onboarding/presentation/widgets/onboarding_step_complete.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  value: (onboardingState.currentStep + 1) / 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
                ),
                SizedBox(height: 16),
                Text(
                  'Step ${onboardingState.currentStep + 1} of 4',
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
                    onboardingState.currentStep == 3 ? 'Complete' : 'Next',
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
        return OnboardingStepPassphrase();
      case 3:
        return OnboardingStepComplete();
      default:
        return OnboardingStepWelcome();
    }
  }

  void _handleNextStep(OnboardingState state, OnboardingNotifier onboardingNotifier) {
    if (state.currentStep == 2) {
      // On passphrase step, validate before proceeding
      // The validation is handled in the OnboardingStepPassphrase widget
      onboardingNotifier.nextStep();
    } else if (state.currentStep == 3) {
      // Complete onboarding
      onboardingNotifier.completeOnboarding();
    } else {
      onboardingNotifier.nextStep();
    }
  }
}
