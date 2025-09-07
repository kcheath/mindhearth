import 'package:mindhearth/core/models/user.dart';

/// Authentication state management
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? user;
  final String? accessToken;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.accessToken,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? user,
    String? accessToken,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  /// Clear error state
  AuthState clearError() {
    return copyWith(error: null);
  }

  /// Set loading state
  AuthState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Set authentication success
  AuthState setAuthenticated(User user, String? accessToken) {
    return copyWith(
      isAuthenticated: true,
      user: user,
      accessToken: accessToken,
      isLoading: false,
      error: null,
    );
  }

  /// Set authentication failure
  AuthState setAuthenticationFailed(String error) {
    return copyWith(
      isAuthenticated: false,
      user: null,
      accessToken: null,
      isLoading: false,
      error: error,
    );
  }

  /// Set error state
  AuthState setError(String error) {
    return copyWith(
      error: error,
      isLoading: false,
    );
  }

  /// Logout
  AuthState logout() {
    return const AuthState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.user == user &&
        other.accessToken == accessToken;
  }

  @override
  int get hashCode {
    return Object.hash(
      isAuthenticated,
      isLoading,
      error,
      user,
      accessToken,
    );
  }

  @override
  String toString() {
    return 'AuthState('
        'isAuthenticated: $isAuthenticated, '
        'isLoading: $isLoading, '
        'error: $error, '
        'user: $user, '
        'accessToken: ${accessToken != null ? '[REDACTED]' : null}'
        ')';
  }
}