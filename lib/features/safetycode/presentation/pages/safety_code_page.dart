import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/safetycode/domain/providers/safety_code_providers.dart';
import 'package:mindhearth/core/config/debug_config.dart';

class SafetyCodePage extends ConsumerStatefulWidget {
  const SafetyCodePage({super.key});

  @override
  ConsumerState<SafetyCodePage> createState() => _SafetyCodePageState();
}

class _SafetyCodePageState extends ConsumerState<SafetyCodePage> {
  final TextEditingController _safetyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No pre-filling - let user enter their own safety code
    print('🐛 Safety code page initialized');
    print('🐛 Controller text: "${_safetyCodeController.text}"');
    
    // Add listener to track controller changes
    _safetyCodeController.addListener(() {
      print('🐛 Controller listener triggered: "${_safetyCodeController.text}"');
    });
  }

  @override
  void dispose() {
    _safetyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safetyCodeState = ref.watch(safetyCodeVerifiedProvider);
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
              Container(
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
                      '🐛 Debug: Test user safety code is "0101190"',
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
              ),
            ],
            SizedBox(height: 48),
            TextField(
              key: ValueKey('safety_code_field'),
              controller: _safetyCodeController,
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
                safetyCodeNotifier.setSafetyCode(value);
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _safetyCodeController.text = '0101190';
                    print('🐛 Debug: Set safety code to 0101190');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('🐛 Debug: Fill Test Code'),
                ),
              ),
            ],
            

          ],
        ),
      ),
    );
  }
}
