import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';
import 'package:mindhearth/features/journal/providers/journal_provider.dart';

class CreateJournalEntryDialog extends ConsumerStatefulWidget {
  final String? sessionId;
  final Function(JournalEntry)? onCreated;

  const CreateJournalEntryDialog({
    Key? key,
    this.sessionId,
    this.onCreated,
  }) : super(key: key);

  @override
  ConsumerState<CreateJournalEntryDialog> createState() => _CreateJournalEntryDialogState();
}

class _CreateJournalEntryDialogState extends ConsumerState<CreateJournalEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _headerController = TextEditingController();
  String? _selectedEntryType;
  List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _headerController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalProvider);
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: const Text('Create Journal Entry'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _headerController,
                        decoration: const InputDecoration(
                          labelText: 'Header (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEntryType,
                        decoration: const InputDecoration(
                          labelText: 'Entry Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Select Type')),
                          DropdownMenuItem(value: 'manual', child: Text('Manual Entry')),
                          DropdownMenuItem(value: 'reflection', child: Text('Reflection')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedEntryType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Tags input
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                labelText: 'Add Tag',
                                border: OutlineInputBorder(),
                              ),
                              onFieldSubmitted: (value) => _addTag(value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _addTag(_tagController.text),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _tags.map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => _removeTag(tag),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content *',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Content is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: journalState.isLoading ? null : _createEntry,
                      child: journalState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _createEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final entry = await ref.read(journalProvider.notifier).createJournalEntry(
      content: _contentController.text.trim(),
      sessionId: widget.sessionId,
      header: _headerController.text.trim().isEmpty ? null : _headerController.text.trim(),
      entryType: _selectedEntryType,
      tags: _tags.isEmpty ? null : _tags,
    );

    if (entry != null) {
      if (widget.onCreated != null) {
        widget.onCreated!(entry);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(journalProvider).error ?? 'Failed to create journal entry'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
