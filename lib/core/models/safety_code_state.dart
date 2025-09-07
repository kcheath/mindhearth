/// Safety code management state
class SafetyCodeState {
  final bool hasSafetyCodes;
  final bool isSafetyCodeVerified;
  final String? currentSafetyCode;
  final bool isLoading;
  final String? error;

  const SafetyCodeState({
    this.hasSafetyCodes = false,
    this.isSafetyCodeVerified = false,
    this.currentSafetyCode,
    this.isLoading = false,
    this.error,
  });

  SafetyCodeState copyWith({
    bool? hasSafetyCodes,
    bool? isSafetyCodeVerified,
    String? currentSafetyCode,
    bool? isLoading,
    String? error,
  }) {
    return SafetyCodeState(
      hasSafetyCodes: hasSafetyCodes ?? this.hasSafetyCodes,
      isSafetyCodeVerified: isSafetyCodeVerified ?? this.isSafetyCodeVerified,
      currentSafetyCode: currentSafetyCode ?? this.currentSafetyCode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Set safety codes
  SafetyCodeState setSafetyCodes() {
    return copyWith(
      hasSafetyCodes: true,
      isSafetyCodeVerified: false,
      error: null,
    );
  }

  /// Verify safety code
  SafetyCodeState verifySafetyCode(String code) {
    return copyWith(
      isSafetyCodeVerified: true,
      currentSafetyCode: code,
      error: null,
    );
  }

  /// Clear safety codes
  SafetyCodeState clearSafetyCodes() {
    return const SafetyCodeState();
  }

  /// Reset verification status
  SafetyCodeState resetVerification() {
    return copyWith(
      isSafetyCodeVerified: false,
      currentSafetyCode: null,
    );
  }

  /// Set loading state
  SafetyCodeState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set error state
  SafetyCodeState setError(String error) {
    return copyWith(error: error, isLoading: false);
  }

  /// Clear error state
  SafetyCodeState clearError() {
    return copyWith(error: null);
  }

  /// Check if safety codes are set up
  bool get isSetUp => hasSafetyCodes;

  /// Check if safety code is verified
  bool get isVerified => isSafetyCodeVerified;

  /// Check if safety code verification is required
  bool get isVerificationRequired => hasSafetyCodes && !isSafetyCodeVerified;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SafetyCodeState &&
        other.hasSafetyCodes == hasSafetyCodes &&
        other.isSafetyCodeVerified == isSafetyCodeVerified &&
        other.currentSafetyCode == currentSafetyCode &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasSafetyCodes,
      isSafetyCodeVerified,
      currentSafetyCode,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'SafetyCodeState('
        'hasSafetyCodes: $hasSafetyCodes, '
        'isSafetyCodeVerified: $isSafetyCodeVerified, '
        'currentSafetyCode: ${currentSafetyCode != null ? '[REDACTED]' : null}, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}
