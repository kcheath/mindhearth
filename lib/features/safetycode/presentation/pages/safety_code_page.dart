import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:go_router/go_router.dart';

class SafetyCodePage extends ConsumerStatefulWidget {
  const SafetyCodePage({super.key});

  @override
  ConsumerState<SafetyCodePage> createState() => _SafetyCodePageState();
}

class _SafetyCodePageState extends ConsumerState<SafetyCodePage> {
  // Use instance controller to allow proper cleanup
  late final TextEditingController _safetyCodeController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    
    _safetyCodeController = TextEditingController();
    _focusNode = FocusNode();
    
    if (LoggingConfig.enableSafetyCodeLogs) {
      appLogger.safetyCode('page_initialized', null);
    }
    
    // Add listener to track controller changes
    _safetyCodeController.addListener(() {
      if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('controller_text_changed', null);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LoggingConfig.enableSafetyCodeLogs) {
      appLogger.safetyCode('dependencies_changed', null);
    }
  }

  @override
  void dispose() {
    _safetyCodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getStoredSafetyCodes() {
    // This would need to be async in a real implementation
    // For now, return a placeholder
    return 'No safety codes stored';
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    
    // Listen for safety code verification changes
    ref.listen<AppState>(appStateProvider, (previous, next) {
      if (next.isSafetyCodeVerified != previous?.isSafetyCodeVerified) {
        if (LoggingConfig.enableSafetyCodeLogs) {
          appLogger.safetyCode('verification_state_changed', {'isVerified': next.isSafetyCodeVerified});
        }
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Code')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 100,
              color: Color(0xFF6750A4),
            ),
            SizedBox(height: 24),
            Text(
              'Safety Code Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Please enter your safety code to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            if (DebugConfig.isDebugMode) ...[
              SizedBox(height: 8),
              FutureBuilder<Map<String, String>?>(
                future: EncryptionService.getSafetyCodes(),
                builder: (context, snapshot) {
                  final storedCodes = snapshot.data;
                  final codesText = storedCodes != null && storedCodes.isNotEmpty
                      ? 'Stored codes: ${storedCodes.values.join(', ')}'
                      : 'No safety codes stored';
                  
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🐛 Debug: $codesText',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '🐛 Current text field value: "${_safetyCodeController.text}"',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            SizedBox(height: 48),
            TextField(
              key: ValueKey('safety_code_field'),
              controller: _safetyCodeController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Safety Code',
                hintText: 'Enter your safety code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: true,
              keyboardType: TextInputType.number,
              autofocus: false,
              onChanged: (value) {
                if (LoggingConfig.enableSafetyCodeLogs) {
                  appLogger.safetyCode('input_changed', null);
                }
                // Don't update state on every keystroke - only when verify button is pressed
              },
              onTap: () {
                if (LoggingConfig.enableSafetyCodeLogs) {
                  appLogger.safetyCode('field_tapped', null);
                }
              },
              onEditingComplete: () {
                if (LoggingConfig.enableSafetyCodeLogs) {
                  appLogger.safetyCode('editing_completed', null);
                }
              },
            ),
            SizedBox(height: 24),
            if (appState.error != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  appState.error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: appState.isLoading
                    ? null
                    : () {
                        if (LoggingConfig.enableSafetyCodeLogs) {
                          appLogger.safetyCode('verify_button_pressed', null);
                        }
                        final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
                        appStateNotifier.verifySafetyCode(_safetyCodeController.text);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: appState.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify Safety Code'),
              ),
            ),
            if (DebugConfig.isDebugMode) ...[
              SizedBox(height: 16),
              FutureBuilder<Map<String, String>?>(
                future: EncryptionService.getSafetyCodes(),
                builder: (context, snapshot) {
                  final storedCodes = snapshot.data;
                  
                  return Column(
                    children: [
                      if (storedCodes != null && storedCodes.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final firstCode = storedCodes.values.first;
                              _safetyCodeController.text = firstCode;
                              if (LoggingConfig.enableSafetyCodeLogs) {
                                appLogger.safetyCode('debug_fill_first_code', null);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('🐛 Debug: Fill First Stored Code'),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Reset Onboarding Flow'),
                                content: Text('This will reset your onboarding progress and log you out. You will need to complete onboarding again.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Reset'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              if (LoggingConfig.enableOnboardingLogs) {
                                appLogger.onboarding('reset_from_safety_page', null);
                              }
                              
                              try {
                                // Show loading indicator
                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      content: Row(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(width: 16),
                                          Text('Resetting onboarding flow...'),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                // Use unified app state notifier for reset
                                if (LoggingConfig.enableOnboardingLogs) {
                                  appLogger.onboarding('using_unified_app_state', null);
                                }
                                final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
                                await appStateNotifier.resetOnboarding();

                                // Close loading dialog and show success message
                                if (LoggingConfig.enableOnboardingLogs) {
                                  appLogger.onboarding('reset_completed_successfully', null);
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // Close loading dialog
                                  _showSuccessDialog(context, 'Onboarding flow has been reset. You will be redirected to login.');
                                }

                              } catch (e) {
                                // Close loading dialog
                                appLogger.error('Error during onboarding reset', {'error': e.toString()});
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  _showErrorDialog(context, 'An error occurred while resetting the onboarding flow: $e');
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('🐛 Debug: Reset Onboarding Flow'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            

          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                context.go('/login');
              },
            ),
          ],
        );
      },
    );
  }
}
