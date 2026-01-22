import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/models/user.dart';
import 'package:mindhearth/core/domain/usecases/auth_usecases.dart';
import 'package:mindhearth/core/providers/usecase_providers.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;
  final UpdateOnboardingStatusUseCase _updateOnboardingStatusUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsAuthenticatedUseCase isAuthenticatedUseCase,
    required UpdateOnboardingStatusUseCase updateOnboardingStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _isAuthenticatedUseCase = isAuthenticatedUseCase,
        _updateOnboardingStatusUseCase = updateOnboardingStatusUseCase,
        super(const AuthState());

  /// Login user
  Future<void> login(String email, String password) async {
    state = state.setLoading(true);
    
    try {
      final result = await _loginUseCase(email, password);
      
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
      final result = await _logoutUseCase();
      
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
      final result = await _getCurrentUserUseCase();
      
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
      final result = await _isAuthenticatedUseCase();
      
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
      final result = await _updateOnboardingStatusUseCase(isOnboarded);
      
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
          
          // Start a background retry to ensure the status is properly synced
          _retryOnboardingStatusUpdate(isOnboarded);
        },
        failure: (error) {
          // Don't set error state for onboarding status updates to avoid blocking the user
          // Just log the error and continue
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Failed to update onboarding status', {
              'error': error.message,
            });
          }
          
          // Start a background retry
          _retryOnboardingStatusUpdate(isOnboarded);
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
      
      // Start a background retry
      _retryOnboardingStatusUpdate(isOnboarded);
    }
  }
  
  /// Retry onboarding status update in the background
  void _retryOnboardingStatusUpdate(bool isOnboarded) {
    // Retry after 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        final result = await _updateOnboardingStatusUseCase(isOnboarded);
        
        result.when(
          success: (_) {
            if (LoggingConfig.enableAuthLogs) {
              appLogger.auth('Onboarding status retry successful', {
                'isOnboarded': isOnboarded,
              });
            }
          },
          failure: (error) {
            if (LoggingConfig.enableAuthLogs) {
              appLogger.auth('Onboarding status retry failed', {
                'error': error.message,
              });
            }
          },
        );
      } catch (e) {
        if (LoggingConfig.enableAuthLogs) {
          appLogger.auth('Onboarding status retry error', {
            'error': e.toString(),
          });
        }
      }
    });
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.setLoading(loading);
  }
}

/// Authentication state provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    isAuthenticatedUseCase: ref.watch(isAuthenticatedUseCaseProvider),
    updateOnboardingStatusUseCase: ref.watch(updateOnboardingStatusUseCaseProvider),
  );
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
