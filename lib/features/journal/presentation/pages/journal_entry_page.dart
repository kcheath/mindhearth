import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/core/providers/journal_provider.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/models/journal_state.dart';
import 'package:mindhearth/core/utils/logger.dart';

class JournalEntryPage extends ConsumerStatefulWidget {
  final String entryId;
  
  const JournalEntryPage({
    super.key,
    required this.entryId,
  });

  @override
  ConsumerState<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends ConsumerState<JournalEntryPage> {
  late TextEditingController _headerController;
  late TextEditingController _contentController;
  late String _selectedType;
  late List<String> _selectedTags;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isGeneratingPreview = false;
  bool _showRedactionPreview = false;
  String? _redactedPreview;
  Map<String, dynamic>? _redactionSummary;
  double? _confidenceScore;
  List<Map<String, dynamic>> _availableTags = [];
  bool _isGeneratingAISummary = false;
  JournalEntry? _entry;

  @override
  void initState() {
    super.initState();
    _headerController = TextEditingController();
    _contentController = TextEditingController();
    _selectedType = 'general';
    _selectedTags = [];
    
    // Load the journal entry and available tags
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntry();
      _loadAvailableTags();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadEntry() async {
    // First try to get the entry from the current state
    var entry = ref.read(journalNotifierProvider.notifier).getEntryById(widget.entryId);

    // If not found in state, load it from the API
    entry ??= await ref.read(journalNotifierProvider.notifier).loadJournalEntry(widget.entryId);

    if (entry != null && mounted) {
      final nonNullEntry = entry;
      setState(() {
        _entry = nonNullEntry;
        _headerController.text = nonNullEntry.header ?? '';
        
        // Parse JSON content if it's in JSON format
        String content = nonNullEntry.originalContent ?? '';
        try {
          // Check if content has markdown code block formatting
          if (content.trim().startsWith('```json') && content.trim().endsWith('```')) {
            // Remove markdown code block markers
            content = content.trim();
            content = content.substring(7); // Remove ```json
            content = content.substring(0, content.length - 3); // Remove ```
            content = content.trim();
            
            // Now parse the JSON
            if (content.startsWith('{') && content.endsWith('}')) {
              final jsonData = jsonDecode(content);
              // Extract the summary or content from JSON
              content = jsonData['summary'] ?? jsonData['content'] ?? content;
            }
          }
          // Check if content is plain JSON (without markdown)
          else if (content.trim().startsWith('{') && content.trim().endsWith('}')) {
            final jsonData = jsonDecode(content);
            // Extract the summary or content from JSON
            content = jsonData['summary'] ?? jsonData['content'] ?? content;
          }
        } catch (e) {
          // If JSON parsing fails, use original content
          appLogger.debug('Failed to parse JSON content: $e');
        }
        
        _contentController.text = content;
        _selectedType = nonNullEntry.entryType ?? 'general';
        _selectedTags = List<String>.from(nonNullEntry.keywords);
      });
    }
  }

  void _loadAvailableTags() async {
    try {
      final tags = await ref.read(journalNotifierProvider.notifier).getJournalTagConfigurations();
      if (mounted) {
        setState(() {
          _availableTags = tags;
        });
      }
    } catch (e) {
      // Handle error silently, will use default tags
    }
  }

  void _updateSelectedTags(String tagName, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedTags.contains(tagName)) {
          _selectedTags.add(tagName);
        }
      } else {
        _selectedTags.remove(tagName);
      }
    });
  }

  Future<void> _generateRedactionPreview() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content first')),
      );
      return;
    }

    setState(() {
      _isGeneratingPreview = true;
    });

    try {
      final redactionService = ref.read(redactionServiceProvider);
      
      // For now, use a basic redaction profile
      // In a real implementation, this would come from user settings
      final redactionProfile = {
        'redact_names': true,
        'redact_emails': true,
        'redact_phones': true,
        'redact_addresses': true,
      };

      final result = await redactionService.preprocessContent(
        _contentController.text,
        redactionProfile,
      );
      
      if (mounted) {
        setState(() {
          _redactedPreview = result['redacted_text'] ?? _contentController.text;
          _redactionSummary = result['redaction_summary'] ?? {};
          _confidenceScore = result['confidence_score']?.toDouble() ?? 0.0;
          _showRedactionPreview = true;
          _isGeneratingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingPreview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating preview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleRedactionPreview() {
    setState(() {
      _showRedactionPreview = !_showRedactionPreview;
    });
  }

  Future<void> _generateAISummary() async {
    if (_entry?.sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No session available for AI summary')),
      );
      return;
    }

    setState(() {
      _isGeneratingAISummary = true;
    });

    try {
      // Use the dedicated AI journal summary endpoint (backend confirmed working!)
      final aiEntry = await ref.read(journalNotifierProvider.notifier).createAIJournalEntry(
        sessionId: _entry!.sessionId!,
      );
      
      if (aiEntry != null && mounted) {
        setState(() {
          _headerController.text = aiEntry.header;
          _contentController.text = aiEntry.originalContent ?? '';
          _selectedTags = List<String>.from(aiEntry.keywords);
          _isGeneratingAISummary = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI summary generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }
    } catch (e) {
      // Log the error and show user-friendly message
      appLogger.error('AI summary generation failed: $e');
      if (mounted) {
        setState(() {
          _isGeneratingAISummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate AI summary: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveEntry() async {
    if (_entry == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedEntry = await ref.read(journalNotifierProvider.notifier).updateJournalEntry(
        entryId: _entry!.id,
        header: _headerController.text,
        entryType: _selectedType,
        originalContent: _contentController.text,
        consent: _entry!.consent, // Keep existing consent value
        keywords: _selectedTags,
        isAIGenerated: _entry!.isAIGenerated,
      );

      if (updatedEntry != null && mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update entry: ${e.toString()}')),
        );
      }
    }
  }

  void _deleteEntry() async {
    if (_entry == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await ref.read(journalNotifierProvider.notifier).deleteJournalEntry(_entry!.id);
        
        if (mounted) {
          if (success) {
            context.go('/journal');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Journal entry deleted successfully')),
            );
          } else {
            setState(() {
              _isLoading = false;
            });
            
            final error = ref.read(journalNotifierProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete entry: ${error ?? 'Unknown error'}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete entry: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entry == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Journal Entry'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/journal'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Journal Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/journal'),
        ),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteEntry();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: _isLoading ? null : () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveEntry,
              child: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
            ),
          ],
        ],
      ),
      body: _isLoading && _isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Entry metadata
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _entry!.formattedDate,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _entry!.entryType.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_entry!.sessionId != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'From chat session',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title field
                  Text(
                    'Title',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _headerController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter journal entry title',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Type field (only show when editing)
                  if (_isEditing) ...[
                    Text(
                      'Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('General')),
                        DropdownMenuItem(value: 'reflection', child: Text('Reflection')),
                        DropdownMenuItem(value: 'gratitude', child: Text('Gratitude')),
                        DropdownMenuItem(value: 'goal', child: Text('Goal Setting')),
                        DropdownMenuItem(value: 'conversation_summary', child: Text('Conversation Summary')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Content field
                  Text(
                    'Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          enabled: _isEditing,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Write your thoughts here...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              onPressed: _isGeneratingPreview ? null : _generateRedactionPreview,
                              icon: _isGeneratingPreview
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.security),
                              tooltip: 'Generate Redaction Preview',
                            ),
                            if (_entry?.sessionId != null)
                              IconButton(
                                onPressed: _isGeneratingAISummary ? null : _generateAISummary,
                                icon: _isGeneratingAISummary
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.auto_awesome),
                                tooltip: 'Generate AI Summary from Session',
                              ),
                            if (_showRedactionPreview)
                              IconButton(
                                onPressed: _toggleRedactionPreview,
                                icon: const Icon(Icons.visibility_off),
                                tooltip: 'Hide Preview',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  
                  // Redaction Preview
                  if (_showRedactionPreview && _redactedPreview != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.orange.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.security, color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'Redaction Preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (_confidenceScore != null)
                                Text(
                                  'Confidence: ${(_confidenceScore! * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _redactedPreview!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          if (_redactionSummary != null && _redactionSummary!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _redactionSummary!.entries.map((entry) {
                                if (entry.value > 0) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Tags Section
                  if (_isEditing) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Selected Tags
                    if (_selectedTags.isNotEmpty) ...[
                      const Text(
                        'Selected Tags:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTags.map((tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedTags.remove(tag);
                            });
                          },
                          backgroundColor: Theme.of(context).primaryColor,
                          deleteIconColor: Colors.white,
                          labelStyle: const TextStyle(color: Colors.white),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Available Tags
                    const Text(
                      'Available Tags:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final tagName = tag['tag_name'] as String;
                        final isSelected = _selectedTags.contains(tagName);
                        
                        return FilterChip(
                          label: Text(tagName),
                          selected: isSelected,
                          onSelected: (selected) => _updateSelectedTags(tagName, selected),
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
