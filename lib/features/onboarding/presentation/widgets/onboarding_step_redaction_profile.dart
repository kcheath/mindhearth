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
  String? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    // Register the save callback with the parent
    widget.onSave(_saveRedactionProfile);
  }

  void _saveRedactionProfile() {
    if (_selectedProfileId != null) {
      final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
      appStateNotifier.setRedactionProfile(_selectedProfileId!);
    }
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
          'Choose Your Privacy Level',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Select how you want your data to be processed and protected. You can change this later in settings.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Redaction profile options
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: onboardingData.redactionProfiles.length,
            itemBuilder: (context, index) {
              final profile = onboardingData.redactionProfiles[index];
              final isSelected = _selectedProfileId == profile.id;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Color(0xFF6750A4).withOpacity(0.1) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Color(0xFF6750A4) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedProfileId = profile.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Color(0xFF6750A4) : Colors.grey[800],
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF6750A4),
                                size: 24,
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          profile.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12),
                        // Redaction rules
                        Text(
                          'Privacy Rules:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        ...profile.redactionRules.entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  entry.value ? Icons.check_circle : Icons.cancel,
                                  size: 16,
                                  color: entry.value ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatRedactionRule(entry.key),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
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
