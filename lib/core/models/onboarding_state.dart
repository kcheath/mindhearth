import 'package:mindhearth/core/models/onboarding_data.dart';

/// Onboarding flow state management
class OnboardingState {
  final bool isOnboarding;
  final int currentStep;
  final bool isOnboardingCompleted;
  final OnboardingData? onboardingData;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.isOnboarding = false,
    this.currentStep = 0,
    this.isOnboardingCompleted = false,
    this.onboardingData,
    this.isLoading = false,
    this.error,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.isOnboarding == isOnboarding &&
        other.currentStep == currentStep &&
        other.isOnboardingCompleted == isOnboardingCompleted &&
        other.onboardingData == onboardingData &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      isOnboarding,
      currentStep,
      isOnboardingCompleted,
      onboardingData,
      isLoading,
      error,
    );
  }

  OnboardingState copyWith({
    bool? isOnboarding,
    int? currentStep,
    bool? isOnboardingCompleted,
    OnboardingData? onboardingData,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      isOnboarding: isOnboarding ?? this.isOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      onboardingData: onboardingData ?? this.onboardingData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Start onboarding flow
  OnboardingState startOnboarding() {
    return copyWith(
      isOnboarding: true,
      currentStep: 0,
      error: null,
    );
  }

  /// Move to next step
  OnboardingState nextStep() {
    return copyWith(
      currentStep: currentStep + 1,
      error: null,
    );
  }

  /// Move to previous step
  OnboardingState previousStep() {
    if (currentStep > 0) {
      return copyWith(
        currentStep: currentStep - 1,
        error: null,
      );
    }
    return this;
  }

  /// Jump to specific step
  OnboardingState goToStep(int step) {
    return copyWith(
      currentStep: step,
      error: null,
    );
  }

  /// Complete onboarding
  OnboardingState completeOnboarding() {
    return copyWith(
      isOnboarding: false,
      isOnboardingCompleted: true,
      currentStep: 0,
      error: null,
    );
  }

  /// Reset onboarding
  OnboardingState resetOnboarding() {
    return const OnboardingState();
  }

  /// Set loading state
  OnboardingState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set error state
  OnboardingState setError(String error) {
    return copyWith(error: error, isLoading: false);
  }

  /// Clear error state
  OnboardingState clearError() {
    return copyWith(error: null);
  }

  /// Update onboarding data
  OnboardingState updateOnboardingData(OnboardingData data) {
    return copyWith(onboardingData: data);
  }

  /// Check if onboarding is in progress
  bool get isInProgress => isOnboarding && !isOnboardingCompleted;

  /// Check if onboarding is completed
  bool get isCompleted => isOnboardingCompleted;

  /// Get total number of steps (based on current implementation)
  int get totalSteps => 8;

  /// Check if we can go to next step
  bool get canGoNext => currentStep < totalSteps - 1;

  /// Check if we can go to previous step
  bool get canGoPrevious => currentStep > 0;

  @override
  String toString() {
    return 'OnboardingState('
        'isOnboarding: $isOnboarding, '
        'currentStep: $currentStep, '
        'isOnboardingCompleted: $isOnboardingCompleted, '
        'onboardingData: $onboardingData, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}
