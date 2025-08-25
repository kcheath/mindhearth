import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/utils/logger.dart';

class PrivacySecuritySettingsPage extends ConsumerWidget {
  const PrivacySecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.visibility_outlined),
                    title: const Text('Data Visibility'),
                    subtitle: const Text('Control who can see your data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to data visibility settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('Data Sharing'),
                    subtitle: const Text('Manage data sharing preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to data sharing settings
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Security Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Safety Code'),
                    subtitle: const Text('Manage your safety code'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to safety code management
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to password change
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Data Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.refresh_outlined),
                    title: const Text('Reset Onboarding Flow'),
                    subtitle: const Text('Clear onboarding progress and start fresh on next login'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showResetOnboardingDialog(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete Account'),
                    subtitle: const Text('Permanently delete your account and data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to account deletion
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetOnboardingDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Onboarding Flow'),
          content: const Text(
            'This will clear your onboarding progress and safety code. '
            'You will need to complete the onboarding process again on your next login. '
            'Are you sure you want to continue?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetOnboardingFlow(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetOnboardingFlow(BuildContext context, WidgetRef ref) async {
    try {
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('starting_reset', null);
      }
      
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
