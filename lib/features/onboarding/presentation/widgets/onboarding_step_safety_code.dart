import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';

class OnboardingStepSafetyCode extends ConsumerStatefulWidget {
  final Function(VoidCallback) onSave;
  
  const OnboardingStepSafetyCode({
    super.key,
    required this.onSave,
  });

  @override
  ConsumerState<OnboardingStepSafetyCode> createState() => _OnboardingStepSafetyCodeState();
}

class _OnboardingStepSafetyCodeState extends ConsumerState<OnboardingStepSafetyCode> {
  final TextEditingController _journalCodeController = TextEditingController();
  final TextEditingController _safeCodeController = TextEditingController();
  final TextEditingController _wipeCodeController = TextEditingController();
  
  bool _obscureJournalCode = true;
  bool _obscureSafeCode = true;
  bool _obscureWipeCode = true;
  
  bool _enableSafetyCodes = false;

  @override
  void initState() {
    super.initState();
    _journalCodeController.addListener(_updateSafetyCodes);
    _safeCodeController.addListener(_updateSafetyCodes);
    _wipeCodeController.addListener(_updateSafetyCodes);
    
    // Register the save callback with the parent
    widget.onSave(_saveSafetyCodes);
  }

  @override
  void dispose() {
    _journalCodeController.dispose();
    _safeCodeController.dispose();
    _wipeCodeController.dispose();
    super.dispose();
  }

  void _updateSafetyCodes() {
    // This method is now only used for local validation
    // State updates are handled by _saveSafetyCodes()
  }
  
  void _saveSafetyCodes() {
    if (_enableSafetyCodes) {
      final codes = <String, String>{};
      if (_journalCodeController.text.isNotEmpty) {
        codes['journal'] = _journalCodeController.text;
      }
      if (_safeCodeController.text.isNotEmpty) {
        codes['safe'] = _safeCodeController.text;
      }
      if (_wipeCodeController.text.isNotEmpty) {
        codes['wipe'] = _wipeCodeController.text;
      }
      
      // Only update if we have at least one code
      if (codes.isNotEmpty) {
        final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
        appStateNotifier.setSafetyCodes(codes);
      }
    }
  }

  Widget _buildCodeInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required Function(bool) onObscureChanged,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            size: 18,
          ),
          onPressed: () => onObscureChanged(!obscureText),
        ),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.security,
          size: 60,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 16),
        Text(
          'Safety Codes (Optional)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'You can set up safety codes to access security features. These are optional and can be added later.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        
        // Enable Safety Codes Toggle
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.grey[700],
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Set up safety codes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Switch(
                value: _enableSafetyCodes,
                onChanged: (value) {
                  setState(() {
                    _enableSafetyCodes = value;
                    if (!value) {
                      // Clear codes when disabled
                      _journalCodeController.clear();
                      _safeCodeController.clear();
                      _wipeCodeController.clear();
                      final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
                      appStateNotifier.setSafetyCodes({});
                    }
                  });
                },
                activeColor: Color(0xFF6750A4),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        
        // Safety Code Input Fields
        if (_enableSafetyCodes) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Your Safety Codes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 8),
                // Journal Code
                _buildCodeInputField(
                  controller: _journalCodeController,
                  label: 'Journal Code',
                  hint: 'Enter code for journal access',
                  obscureText: _obscureJournalCode,
                  onObscureChanged: (value) => setState(() => _obscureJournalCode = value),
                  icon: Icons.book,
                ),
                SizedBox(height: 6),
                // Safe Code
                _buildCodeInputField(
                  controller: _safeCodeController,
                  label: 'Safe Code',
                  hint: 'Enter code for safe screen',
                  obscureText: _obscureSafeCode,
                  onObscureChanged: (value) => setState(() => _obscureSafeCode = value),
                  icon: Icons.security,
                ),
                SizedBox(height: 6),
                // Wipe Code
                _buildCodeInputField(
                  controller: _wipeCodeController,
                  label: 'Wipe Code',
                  hint: 'Enter code for data wipe',
                  obscureText: _obscureWipeCode,
                  onObscureChanged: (value) => setState(() => _obscureWipeCode = value),
                  icon: Icons.delete_forever,
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
        
        // Security Information
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange[700],
                size: 14,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  _enableSafetyCodes 
                    ? 'Write down your safety codes and keep them in a safe place. You\'ll need them to access security features.'
                    : 'Safety codes are optional. You can add them later in settings if needed.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
