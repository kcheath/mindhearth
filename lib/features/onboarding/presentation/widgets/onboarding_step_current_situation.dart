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
  String? _selectedSituationId;

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
    widget.onSave(_saveCurrentSituation);
  }

  void _saveCurrentSituation() {
    if (_selectedSituationId != null) {
      final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
      appStateNotifier.setCurrentSituation(_selectedSituationId!);
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
          Icons.psychology,
          size: 80,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 24),
        Text(
          'What brings you here today?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Select the situation that best describes your current circumstances. This helps us provide more relevant support.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),

        // Situation options
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: onboardingData.currentSituations.length,
            itemBuilder: (context, index) {
              final situation = onboardingData.currentSituations[index];
              final isSelected = _selectedSituationId == situation.id;

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
                      _selectedSituationId = situation.id;
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
                                situation.title,
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
                          situation.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: situation.tags.map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF6750A4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6750A4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
}
