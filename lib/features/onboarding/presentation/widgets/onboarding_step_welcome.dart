import 'package:flutter/material.dart';

class OnboardingStepWelcome extends StatelessWidget {
  const OnboardingStepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.psychology,
          size: 100,
          color: Color(0xFF6750A4),
        ),
        SizedBox(height: 32),
        Text(
          'Welcome to Mindhearth',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Your AI-powered mental health companion',
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
              _buildFeatureItem(
                Icons.chat_bubble_outline,
                'AI Chat Support',
                'Get personalized mental health guidance through conversation',
              ),
              SizedBox(height: 16),
              _buildFeatureItem(
                Icons.security_outlined,
                'Privacy First',
                'Your data is encrypted and secure',
              ),
              SizedBox(height: 16),
              _buildFeatureItem(
                Icons.psychology_outlined,
                'Professional Tools',
                'Access to therapeutic techniques and exercises',
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Let\'s get you set up with a secure, personalized experience.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFF6750A4),
          size: 24,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
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
