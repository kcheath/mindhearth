import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/safetycode/domain/providers/safety_code_providers.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:go_router/go_router.dart';

class SafetyCodePage extends ConsumerStatefulWidget {
  const SafetyCodePage({super.key});

  @override
  ConsumerState<SafetyCodePage> createState() => _SafetyCodePageState();
}

class _SafetyCodePageState extends ConsumerState<SafetyCodePage> {
  // Use a static controller to prevent recreation on rebuilds
  static final TextEditingController _safetyCodeController = TextEditingController();
  static bool _isInitialized = false;
  static final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    if (!_isInitialized) {
      // Only initialize once
      print('🐛 Safety code page initialized');
      print('🐛 Controller text: "${_safetyCodeController.text}"');
      
      // Add listener to track controller changes
      _safetyCodeController.addListener(() {
        print('🐛 Controller listener triggered: "${_safetyCodeController.text}"');
      });
      
      _isInitialized = true;
    } else {
      print('🐛 Safety code page reinitialized, controller text: "${_safetyCodeController.text}"');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🐛 Safety code page dependencies changed');
    print('🐛 Controller text after dependencies: "${_safetyCodeController.text}"');
  }

  // Static method to clear the controller when needed
  static void clearController() {
    _safetyCodeController.clear();
    print('🐛 Controller cleared');
  }

  @override
  void dispose() {
    // Don't dispose the static controller as it's shared across instances
    super.dispose();
  }

  String _generateSafetyCodeFromPassphrase(String? passphrase) {
    if (passphrase == null || passphrase.isEmpty) {
      return 'No passphrase set';
    }
    
    // Use the same logic as the onboarding provider
    final hash = passphrase.hashCode.toString();
    final journalCode = (hash.length >= 8) ? hash.substring(0, 8) : hash.padRight(8, '0');
    
    return journalCode;
  }

  @override
  Widget build(BuildContext context) {
    // Use listen instead of watch to prevent unnecessary rebuilds
    ref.listen(safetyCodeVerifiedProvider, (previous, next) {
      print('🐛 Safety code state changed: ${next.isVerified}');
    });
    
    final safetyCodeState = ref.read(safetyCodeVerifiedProvider);
    final safetyCodeNotifier = ref.read(safetyCodeNotifierProvider.notifier);
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
              Builder(
                builder: (context) {
                  final onboardingState = ref.watch(onboardingStateProvider);
                  final generatedCode = _generateSafetyCodeFromPassphrase(onboardingState.passphrase);
                  
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
                          '🐛 Debug: Generated safety code is "$generatedCode"',
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
                print('🐛 Safety code input changed: $value');
                print('🐛 Controller text after change: "${_safetyCodeController.text}"');
                // Don't update state on every keystroke - only when verify button is pressed
              },
              onTap: () {
                print('🐛 Safety code field tapped');
                print('🐛 Controller text on tap: "${_safetyCodeController.text}"');
              },
              onEditingComplete: () {
                print('🐛 Safety code editing completed');
                print('🐛 Final controller text: "${_safetyCodeController.text}"');
              },
            ),
            SizedBox(height: 24),
            if (safetyCodeState.error != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  safetyCodeState.error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: safetyCodeState.isLoading
                    ? null
                    : () {
                        print('🐛 Verify button pressed with text: "${_safetyCodeController.text}"');
                        safetyCodeNotifier.verifySafetyCode(_safetyCodeController.text);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: safetyCodeState.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify Safety Code'),
              ),
            ),
            if (DebugConfig.isDebugMode) ...[
              SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final onboardingState = ref.watch(onboardingStateProvider);
                  final generatedCode = _generateSafetyCodeFromPassphrase(onboardingState.passphrase);
                  
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _safetyCodeController.text = generatedCode;
                            print('🐛 Debug: Set safety code to $generatedCode');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('🐛 Debug: Fill Generated Code'),
                        ),
                      ),
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
                              print('🐛 Debug: Resetting onboarding flow');
                              
                              // Get the auth notifier
                              final authNotifier = ref.read(authNotifierProvider.notifier);
                              final safetyCodeNotifier = ref.read(safetyCodeNotifierProvider.notifier);
                              final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
                              
                              // Reset onboarding status in backend
                              await authNotifier.updateOnboardingStatus(false);
                              
                              // Clear local state
                              safetyCodeNotifier.reset();
                              onboardingNotifier.reset();
                              
                              // Logout and navigate to login
                              authNotifier.logout();
                              context.go('/login');
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
}
