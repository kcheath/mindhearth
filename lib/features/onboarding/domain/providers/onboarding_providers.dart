import 'package:hooks_riverpod/hooks_riverpod.dart';

// Onboarding State
class OnboardingState {
  final bool isOnboarding;
  final int currentStep;
  final bool isCompleted;
  final String? error;

  const OnboardingState({
    this.isOnboarding = false,
    this.currentStep = 0,
    this.isCompleted = false,
    this.error,
  });

  OnboardingState copyWith({
    bool? isOnboarding,
    int? currentStep,
    bool? isCompleted,
    String? error,
  }) {
    return OnboardingState(
      isOnboarding: isOnboarding ?? this.isOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
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
    if (state.currentStep < 3) { // Assuming 4 steps (0-3)
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      completeOnboarding();
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void completeOnboarding() {
    state = state.copyWith(
      isOnboarding: false,
      isCompleted: true,
      currentStep: 0,
    );
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Onboarding State Provider
final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

final onboardingStateProvider = Provider<OnboardingState>((ref) {
  return ref.watch(onboardingNotifierProvider);
});
