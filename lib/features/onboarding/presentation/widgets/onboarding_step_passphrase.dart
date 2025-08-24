import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';

class OnboardingStepPassphrase extends ConsumerStatefulWidget {
  const OnboardingStepPassphrase({super.key});

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
    
    // Update the onboarding provider with the passphrase
    if (_isValid) {
      final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
      onboardingNotifier.setPassphrase(passphrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 100,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 32),
        Text(
          'Create Your Passphrase',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'This will encrypt your data and create your safety codes',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
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
              SizedBox(height: 16),
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
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Important Security Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Your passphrase encrypts all your data\n'
                '• We cannot recover your passphrase if you forget it\n'
                '• Write it down and keep it in a safe place\n'
                '• This will be used to generate your safety codes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        if (_passphraseController.text.isNotEmpty && _confirmPassphraseController.text.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isValid ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isValid ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isValid ? Icons.check_circle : Icons.error,
                  color: _isValid ? Colors.green[700] : Colors.red[700],
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isValid 
                      ? 'Passphrases match and meet requirements'
                      : _passphraseController.text.length < 8
                        ? 'Passphrase must be at least 8 characters'
                        : 'Passphrases do not match',
                    style: TextStyle(
                      fontSize: 14,
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
