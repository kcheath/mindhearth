import 'package:flutter/material.dart';

class OnboardingStepComplete extends StatelessWidget {
  const OnboardingStepComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 60,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        Text(
          'Setup Complete!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Your account is now secure and ready to use',
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
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            children: [
              _buildCompletionItem(
                Icons.security,
                'Data Encrypted',
                'Your data is now encrypted with your passphrase',
              ),
              SizedBox(height: 8),
              _buildCompletionItem(
                Icons.verified_user,
                'Account Secured',
                'Your account is protected with security measures',
              ),
              SizedBox(height: 8),
              _buildCompletionItem(
                Icons.psychology,
                'Ready to Start',
                'You can now begin your mental health journey',
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 16,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your safety codes and passphrase are securely stored. Your data is protected with end-to-end encryption.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
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
                size: 16,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Remember to keep your passphrase safe. You\'ll need it to access your encrypted data.',
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

  Widget _buildCompletionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.green[700],
          size: 18,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
