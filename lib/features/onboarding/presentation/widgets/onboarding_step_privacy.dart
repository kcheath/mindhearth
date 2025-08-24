import 'package:flutter/material.dart';

class OnboardingStepPrivacy extends StatelessWidget {
  const OnboardingStepPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 80,
            color: Color(0xFF6750A4),
          ),
          SizedBox(height: 24),
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'We take your privacy and security seriously',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildPrivacyItem(
                  Icons.lock_outline,
                  'End-to-End Encryption',
                  'All your conversations and data are encrypted',
                ),
                SizedBox(height: 12),
                _buildPrivacyItem(
                  Icons.local_activity_outlined,
                  'Local Processing',
                  'Sensitive data stays on your device',
                ),
                SizedBox(height: 12),
                _buildPrivacyItem(
                  Icons.visibility_off_outlined,
                  'No Data Sharing',
                  'We never share your personal information',
                ),
                SizedBox(height: 12),
                _buildPrivacyItem(
                  Icons.delete_outline,
                  'You Control Your Data',
                  'Delete your data anytime',
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your conversations are private and secure. We use industry-standard encryption to protect your data.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFF6750A4),
          size: 20,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
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
