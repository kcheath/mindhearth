import 'package:flutter/material.dart';

class OnboardingStepWelcome extends StatelessWidget {
  const OnboardingStepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6750A4).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/mindhearth_logo.png',
                fit: BoxFit.cover,
              ),
            ),
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
                  Image.asset('assets/images/mindhearth_logo.png', width: 24, height: 24),
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
      ),
    );
  }

  Widget _buildFeatureItem(dynamic icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon is IconData 
          ? Icon(
              icon,
              color: Color(0xFF6750A4),
              size: 24,
            )
          : icon,
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
