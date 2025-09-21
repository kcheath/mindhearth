import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Reusable journal entry form component
class JournalEntryForm extends ConsumerStatefulWidget {
  final String? initialHeader;
  final String? initialContent;
  final String? initialType;
  final List<String>? initialTags;
  final List<Map<String, dynamic>>? availableTags;
  final bool isEditing;
  final Function(String header, String content, String type, List<String> tags)? onSubmit;
  final VoidCallback? onCancel;

  const JournalEntryForm({
    super.key,
    this.initialHeader,
    this.initialContent,
    this.initialType,
    this.initialTags,
    this.availableTags,
    this.isEditing = false,
    this.onSubmit,
    this.onCancel,
  });

  @override
  ConsumerState<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends ConsumerState<JournalEntryForm> {
  late TextEditingController _headerController;
  late TextEditingController _contentController;
  late String _selectedType;
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _headerController = TextEditingController(text: widget.initialHeader ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
    _selectedType = widget.initialType ?? 'general';
    _selectedTags = List<String>.from(widget.initialTags ?? []);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header field
        TextFormField(
          controller: _headerController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Give your entry a meaningful title',
            border: OutlineInputBorder(),
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 16),

        // Content field
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'Content',
            hintText: 'Share your thoughts, feelings, or experiences...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          minLines: 4,
        ),
        const SizedBox(height: 16),

        // Type selection
        _buildTypeSelector(),
        const SizedBox(height: 16),

        // Tags selection
        if (widget.availableTags != null) ...[
          _buildTagsSelector(),
          const SizedBox(height: 16),
        ],

        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entry Type',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'general',
            'reflection',
            'gratitude',
            'challenge',
            'growth',
          ].map((type) => FilterChip(
            label: Text(type),
            selected: _selectedType == type,
            onSelected: (selected) {
              setState(() {
                _selectedType = type;
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.availableTags!.map((tag) {
            final tagName = tag['name'] as String;
            final isSelected = _selectedTags.contains(tagName);
            
            return FilterChip(
              label: Text(tagName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tagName);
                  } else {
                    _selectedTags.remove(tagName);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onCancel != null)
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(widget.isEditing ? 'Update Entry' : 'Save Entry'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    widget.onSubmit?.call(
      _headerController.text.trim(),
      _contentController.text.trim(),
      _selectedType,
      _selectedTags,
    );
  }
}
