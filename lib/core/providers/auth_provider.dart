import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/models/user.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/domain/usecases/auth_usecases.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login user
  Future<void> login(String email, String password) async {
    state = state.setLoading(true);
    
    try {
      final loginUseCase = serviceLocator.get<LoginUseCase>();
      final result = await loginUseCase(email, password);
      
      result.when(
        success: (user) {
          state = state.setAuthenticated(user, null);
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Login successful', {
              'userId': user.id,
              'email': user.email,
              'isOnboarded': user.isOnboarded,
            });
          }
        },
        failure: (error) {
          state = state.setAuthenticationFailed(error.message);
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Login failed', {
              'email': email,
              'error': error.message,
              'type': error.runtimeType.toString(),
            });
          }
        },
      );
    } catch (e) {
      state = state.setAuthenticationFailed('Login failed: ${e.toString()}');
      
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Login error', {
          'email': email,
          'error': e.toString(),
        });
      }
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final logoutUseCase = serviceLocator.get<LogoutUseCase>();
      final result = await logoutUseCase();
      
      result.when(
        success: (_) {
          state = state.logout();
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Logout successful', {
              'userId': state.user?.id,
            });
          }
        },
        failure: (error) {
          // Even if logout fails on backend, clear local state
          state = state.logout();
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Logout failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      // Even if logout fails, clear local state
      state = state.logout();
      
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Logout error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Get current user
  Future<void> getCurrentUser() async {
    if (!state.isAuthenticated) return;
    
    state = state.setLoading(true);
    
    try {
      final getCurrentUserUseCase = serviceLocator.get<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase();
      
      result.when(
        success: (user) {
          if (user != null) {
            state = state.copyWith(user: user);
            
            if (LoggingConfig.enableAuthLogs) {
              appLogger.auth('Current user loaded', {
                'userId': user.id,
                'email': user.email,
                'isOnboarded': user.isOnboarded,
              });
            }
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Failed to get current user', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to get current user: ${e.toString()}');
      
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Get current user error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      final isAuthenticatedUseCase = serviceLocator.get<IsAuthenticatedUseCase>();
      final result = await isAuthenticatedUseCase();
      
      result.when(
        success: (isAuthenticated) {
          if (isAuthenticated) {
            // User is authenticated, get current user data
            getCurrentUser();
          } else {
            state = state.logout();
          }
        },
        failure: (error) {
          state = state.logout();
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Auth status check failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.logout();
      
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Auth status check error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Update onboarding status
  Future<void> updateOnboardingStatus(bool isOnboarded) async {
    try {
      final updateOnboardingStatusUseCase = serviceLocator.get<UpdateOnboardingStatusUseCase>();
      final result = await updateOnboardingStatusUseCase(isOnboarded);
      
      result.when(
        success: (_) {
          // Update the user's onboarding status in the state
          if (state.user != null) {
            final updatedUser = state.user!.copyWith(isOnboarded: isOnboarded);
            state = state.copyWith(user: updatedUser);
          }
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Onboarding status updated', {
              'isOnboarded': isOnboarded,
            });
          }
        },
        failure: (error) {
          // Don't set error state for onboarding status updates to avoid blocking the user
          // Just log the error and continue
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Failed to update onboarding status', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      // Don't set error state for onboarding status updates to avoid blocking the user
      // Just log the error and continue
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Onboarding status update error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.setLoading(loading);
  }
}

/// Authentication state provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Authentication state provider (read-only)
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

/// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
