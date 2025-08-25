import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';

class OnboardingStepCurrentSituation extends ConsumerStatefulWidget {
  final Function(VoidCallback) onSave;

  const OnboardingStepCurrentSituation({
    super.key,
    required this.onSave,
  });

  @override
  ConsumerState<OnboardingStepCurrentSituation> createState() => _OnboardingStepCurrentSituationState();
}

class _OnboardingStepCurrentSituationState extends ConsumerState<OnboardingStepCurrentSituation> {
  final _ageController = TextEditingController();
  final _stateController = TextEditingController();
  final _childrenController = TextEditingController();
  final _backgroundController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load onboarding data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = ref.read(appStateProvider);
      if (appState.onboardingData == null) {
        ref.read(appStateNotifierProvider.notifier).loadOnboardingData();
      }
    });
    
    // Register the save callback with the parent
    widget.onSave(_saveSituationData);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _stateController.dispose();
    _childrenController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _saveSituationData() {
    final situationData = {
      'age': _ageController.text.isNotEmpty ? _ageController.text : null,
      'state': _stateController.text.isNotEmpty ? _stateController.text : null,
      'children': _childrenController.text.isNotEmpty ? _childrenController.text : null,
      'background': _backgroundController.text.isNotEmpty ? _backgroundController.text : null,
    };
    
    final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
    appStateNotifier.setSituationData(situationData);
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
          Icons.person,
          size: 80,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 24),
        Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'This information helps us provide more personalized support. All fields are optional.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Form fields
        Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age (optional)',
                  hintText: 'e.g., 35',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State/Region (optional)',
                  hintText: 'e.g., California',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _childrenController,
                decoration: InputDecoration(
                  labelText: 'Children (optional)',
                  hintText: 'e.g., 2 children ages 5 and 7',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                maxLines: 1,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _backgroundController,
                decoration: InputDecoration(
                  labelText: 'Additional background (optional)',
                  hintText: 'Any other context that might be helpful...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
