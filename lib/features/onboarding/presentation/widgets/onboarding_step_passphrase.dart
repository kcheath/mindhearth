import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/app_state_provider.dart';

class OnboardingStepPassphrase extends ConsumerStatefulWidget {
  final Function(VoidCallback) onSave;
  
  const OnboardingStepPassphrase({
    super.key,
    required this.onSave,
  });

  @override
  ConsumerState<OnboardingStepPassphrase> createState() => _OnboardingStepPassphraseState();
}

class _OnboardingStepPassphraseState extends ConsumerState<OnboardingStepPassphrase> {
  final TextEditingController _passphraseController = TextEditingController();
  final TextEditingController _confirmPassphraseController = TextEditingController();
  bool _obscurePassphrase = true;
  bool _obscureConfirmPassphrase = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _passphraseController.addListener(_validatePassphrase);
    _confirmPassphraseController.addListener(_validatePassphrase);
    
    // Register the save callback with the parent
    widget.onSave(_savePassphrase);
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmPassphraseController.dispose();
    super.dispose();
  }

  void _validatePassphrase() {
    final passphrase = _passphraseController.text;
    final confirmPassphrase = _confirmPassphraseController.text;
    
    setState(() {
      _isValid = passphrase.length >= 8 && 
                 passphrase == confirmPassphrase &&
                 passphrase.isNotEmpty;
    });
  }
  
  void _savePassphrase() {
    if (_isValid) {
      final passphrase = _passphraseController.text;
      final appStateNotifier = ref.read(appStateNotifierProvider.notifier);
      appStateNotifier.setPassphrase(passphrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 60,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 16),
        Text(
          'Create Your Passphrase',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'This will encrypt your data and create your safety codes',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _passphraseController,
                obscureText: _obscurePassphrase,
                decoration: InputDecoration(
                  labelText: 'Passphrase',
                  hintText: 'Enter a secure passphrase (min 8 characters)',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassphrase ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassphrase = !_obscurePassphrase;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _confirmPassphraseController,
                obscureText: _obscureConfirmPassphrase,
                decoration: InputDecoration(
                  labelText: 'Confirm Passphrase',
                  hintText: 'Re-enter your passphrase',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassphrase ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassphrase = !_obscureConfirmPassphrase;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
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
                  'Your passphrase encrypts all your data. Write it down and keep it safe - we cannot recover it if you forget it.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        if (_passphraseController.text.isNotEmpty && _confirmPassphraseController.text.isNotEmpty)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isValid ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isValid ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isValid ? Icons.check_circle : Icons.error,
                  color: _isValid ? Colors.green[700] : Colors.red[700],
                  size: 14,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _isValid 
                      ? 'Passphrases match and meet requirements'
                      : _passphraseController.text.length < 8
                        ? 'Passphrase must be at least 8 characters'
                        : 'Passphrases do not match',
                    style: TextStyle(
                      fontSize: 11,
                      color: _isValid ? Colors.green[700] : Colors.red[700],
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
