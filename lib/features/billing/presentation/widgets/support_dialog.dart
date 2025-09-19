import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Support dialog for contacting billing support
/// Provides trauma-informed support experience with clear communication
class SupportDialog extends StatefulWidget {
  const SupportDialog({Key? key}) : super(key: key);

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'billing';
  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = [
    {'value': 'billing', 'label': 'Billing & Payments'},
    {'value': 'credits', 'label': 'Credits & Usage'},
    {'value': 'account', 'label': 'Account Issues'},
    {'value': 'technical', 'label': 'Technical Support'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.support_agent,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          const Text('Contact Support'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We\'re here to help with any billing questions or concerns. '
                'Your privacy and security are our top priorities.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              _buildSubjectField(),
              const SizedBox(height: 16),
              _buildMessageField(),
              const SizedBox(height: 16),
              _buildContactInfo(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSubmit() ? _submitSupportRequest : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Send Message'),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['value'],
              child: Text(category['label']!),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
        ),
      ],
    );
  }

  Widget _buildSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          decoration: const InputDecoration(
            hintText: 'Brief description of your issue',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a subject';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Please describe your issue in detail...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a message';
            }
            if (value.trim().length < 10) {
              return 'Please provide more details (at least 10 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Support Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• We typically respond within 24 hours\n'
            '• For urgent issues, please call our support line\n'
            '• All communications are confidential and secure',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Support Email: '),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'support@mindhearth.app'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'support@mindhearth.app',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _subjectController.text.trim().isNotEmpty &&
           _messageController.text.trim().isNotEmpty &&
           _messageController.text.trim().length >= 10 &&
           !_isSubmitting;
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      appLogger.info('Submitting support request', {
        'category': _selectedCategory,
        'subject': _subjectController.text,
        'messageLength': _messageController.text.length,
      });
      
      // In a real implementation, this would send the support request
      // For now, we'll simulate the submission process
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Support request submitted successfully! We\'ll get back to you within 24 hours.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      appLogger.error('Support request failed', {'error': e.toString()});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit support request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
