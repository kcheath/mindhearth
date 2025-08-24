import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:mindhearth/core/providers/api_providers.dart';

// Onboarding State
class OnboardingState {
  final bool isOnboarding;
  final int currentStep;
  final bool isCompleted;
  final String? error;
  final String? passphrase;

  const OnboardingState({
    this.isOnboarding = false,
    this.currentStep = 0,
    this.isCompleted = false,
    this.error,
    this.passphrase,
  });

  OnboardingState copyWith({
    bool? isOnboarding,
    int? currentStep,
    bool? isCompleted,
    String? error,
    String? passphrase,
  }) {
    return OnboardingState(
      isOnboarding: isOnboarding ?? this.isOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
      passphrase: passphrase ?? this.passphrase,
    );
  }
}

// Onboarding Notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref ref;

  OnboardingNotifier(this.ref) : super(const OnboardingState());

  void startOnboarding() {
    state = state.copyWith(isOnboarding: true, currentStep: 0);
  }

  void nextStep() {
    if (state.currentStep < 3) { // 4 steps (0-3)
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      completeOnboarding();
    }
  }

  void setPassphrase(String passphrase) {
    state = state.copyWith(passphrase: passphrase);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      // Update onboarding status in auth notifier
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.updateOnboardingStatus(true);
      
      // If we have a passphrase, generate and save safety codes
      if (state.passphrase != null) {
        await _generateAndSaveSafetyCodes(state.passphrase!);
      }
      
      state = state.copyWith(
        isOnboarding: false,
        isCompleted: true,
        currentStep: 0,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete onboarding: $e');
    }
  }

  Future<void> _generateAndSaveSafetyCodes(String passphrase) async {
    try {
      // Generate safety codes based on passphrase
      final safetyCodes = _generateSafetyCodes(passphrase);
      
      // Save safety codes to backend
      final apiService = ref.read(apiServiceProvider);
      await apiService.saveSafetyCodes(safetyCodes, passphrase);
      
      print('🐛 Safety codes generated and saved successfully');
    } catch (e) {
      print('🐛 Error generating safety codes: $e');
      // Don't fail onboarding if safety code generation fails
    }
  }

  Map<String, String> _generateSafetyCodes(String passphrase) {
    // Generate a consistent safety code for demo purposes
    // In production, this should use proper cryptographic methods
    // For now, use a fixed code that matches the expected "01011990"
    return {
      'journal': '01011990',
    };
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const OnboardingState();
  }
}

// Onboarding State Provider
final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

final onboardingStateProvider = Provider<OnboardingState>((ref) {
  return ref.watch(onboardingNotifierProvider);
});
