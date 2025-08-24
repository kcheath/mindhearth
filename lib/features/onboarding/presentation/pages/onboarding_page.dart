import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';
import 'package:mindhearth/core/config/debug_config.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Mindhearth'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 100,
              color: Color(0xFF6750A4),
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to Mindhearth',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Let\'s get you set up with your personalized experience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 48),
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
            SizedBox(height: 48),
            if (onboardingState.error != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onboardingState.currentStep > 0)
                  ElevatedButton(
                    onPressed: () => onboardingNotifier.previousStep(),
                    child: Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (onboardingState.currentStep == 3) {
                      // Complete onboarding
                      authNotifier.updateOnboardingStatus(true);
                      onboardingNotifier.completeOnboarding();
                    } else {
                      onboardingNotifier.nextStep();
                    }
                  },
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
            

          ],
        ),
      ),
    );
  }
}
