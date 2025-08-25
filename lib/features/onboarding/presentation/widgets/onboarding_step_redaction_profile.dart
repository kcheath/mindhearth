import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';

class OnboardingStepRedactionProfile extends ConsumerStatefulWidget {
  final Function(VoidCallback) onSave;

  const OnboardingStepRedactionProfile({
    super.key,
    required this.onSave,
  });

  @override
  ConsumerState<OnboardingStepRedactionProfile> createState() => _OnboardingStepRedactionProfileState();
}

class _OnboardingStepRedactionProfileState extends ConsumerState<OnboardingStepRedactionProfile> {
  final _userNamesController = TextEditingController();
  final _childNamesController = TextEditingController();
  final _emailsController = TextEditingController();
  final _phoneNumbersController = TextEditingController();
  final _addressController = TextEditingController();
  final _peopleToRedactController = TextEditingController();
  bool _redactPronouns = false;

  @override
  void initState() {
    super.initState();
    // Register the save callback with the parent
    widget.onSave(_saveRedactionProfile);
  }

  @override
  void dispose() {
    _userNamesController.dispose();
    _childNamesController.dispose();
    _emailsController.dispose();
    _phoneNumbersController.dispose();
    _addressController.dispose();
    _peopleToRedactController.dispose();
    super.dispose();
  }

  void _saveRedactionProfile() {
    final profileData = {
      'user_names': _userNamesController.text.isNotEmpty ? _userNamesController.text : null,
      'child_names': _childNamesController.text.isNotEmpty ? _childNamesController.text : null,
      'emails': _emailsController.text.isNotEmpty ? _emailsController.text : null,
      'phone_numbers': _phoneNumbersController.text.isNotEmpty ? _phoneNumbersController.text : null,
      'address': _addressController.text.isNotEmpty ? _addressController.text : null,
      'people_to_redact': _peopleToRedactController.text.isNotEmpty ? _peopleToRedactController.text : null,
      'redact_pronouns': _redactPronouns,
    };
    
    final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
    appStateNotifier.setRedactionProfile(profileData);
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final onboardingData = appState.onboardingData;

    if (onboardingData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load onboarding data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        Icon(
          Icons.security,
          size: 80,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 24),
        Text(
          'Privacy & Redaction Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Tell us what information should be automatically removed from your conversations for privacy.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Redaction form fields
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _userNamesController,
                  decoration: InputDecoration(
                    labelText: 'User names to redact',
                    hintText: 'e.g., John, Jane, Mom, Dad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _childNamesController,
                  decoration: InputDecoration(
                    labelText: 'Child names to redact',
                    hintText: 'e.g., Emma, Liam, Baby',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.child_care),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailsController,
                  decoration: InputDecoration(
                    labelText: 'Email addresses to redact',
                    hintText: 'e.g., john@email.com, jane@work.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumbersController,
                  decoration: InputDecoration(
                    labelText: 'Phone numbers to redact',
                    hintText: 'e.g., 555-123-4567, +1-555-987-6543',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address to redact (optional)',
                    hintText: 'e.g., 123 Main St, Anytown, CA 90210',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _peopleToRedactController,
                  decoration: InputDecoration(
                    labelText: 'Other people to redact',
                    hintText: 'e.g., boss, therapist, friend Sarah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.people),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Redact pronouns'),
                  subtitle: Text('Automatically replace he/she/they with [PERSON]'),
                  value: _redactPronouns,
                  onChanged: (value) {
                    setState(() {
                      _redactPronouns = value;
                    });
                  },
                  activeColor: Color(0xFF6750A4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatRedactionRule(String rule) {
    switch (rule) {
      case 'names':
        return 'Personal names and identifiers';
      case 'addresses':
        return 'Addresses and location details';
      case 'phone_numbers':
        return 'Phone numbers and contact info';
      case 'email_addresses':
        return 'Email addresses';
      case 'specific_dates':
        return 'Specific dates and timestamps';
      case 'locations':
        return 'General locations and places';
      case 'workplace':
        return 'Workplace and job information';
      case 'family_details':
        return 'Family and relationship details';
      default:
        return rule.replaceAll('_', ' ').toUpperCase();
    }
  }
}
