import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/core/providers/journal_provider.dart';
import 'package:mindhearth/core/models/journal_state.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    // Load journal entries when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(journalNotifierProvider.notifier).loadJournalEntries();
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/chat');
        break;
      case 1:
        context.go('/sessions');
        break;
      case 2:
        context.go('/journal');
        break;
      case 3:
        context.go('/documents');
        break;
      case 4:
        context.go('/reports');
        break;
    }
  }

  void _onJournalEntryTap(JournalEntry entry) {
    // Navigate to journal entry detail or edit
    ref.read(journalNotifierProvider.notifier).setCurrentEntry(entry);
    context.go('/journal/${entry.id}');
  }

  void _onRefresh() {
    ref.read(journalNotifierProvider.notifier).refreshJournalEntries();
  }

  void _onCreateEntry() {
    // TODO: Navigate to create journal entry page
    _showCreateEntryDialog();
  }

  void _showCreateEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateJournalEntryDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalStateProvider);
    
    return AdaptiveNavigation(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
            ),
          ],
        ),
        body: _buildBody(context, journalState),
        floatingActionButton: FloatingActionButton(
          onPressed: _onCreateEntry,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, JournalState journalState) {
    if (journalState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (journalState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load journal entries',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              journalState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!journalState.hasEntries) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No Journal Entries Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start writing to reflect on your thoughts and experiences.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _onCreateEntry,
              icon: const Icon(Icons.add),
              label: const Text('Create First Entry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: journalState.entries.length,
        itemBuilder: (context, index) {
          final entry = journalState.entries[index];
          return _buildJournalEntryCard(context, entry);
        },
      ),
    );
  }

  Widget _buildJournalEntryCard(BuildContext context, JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.book_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          entry.header,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.entryType.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  entry.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (entry.isRecent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Recent',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _onJournalEntryTap(entry),
      ),
    );
  }
}

class _CreateJournalEntryDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateJournalEntryDialog> createState() => _CreateJournalEntryDialogState();
}

class _CreateJournalEntryDialogState extends ConsumerState<_CreateJournalEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _headerController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'general';

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      ref.read(journalNotifierProvider.notifier).createJournalEntry(
        header: _headerController.text,
        entryType: _selectedType,
        originalContent: _contentController.text,
        metaData: {
          'content': _contentController.text,
        },
        consent: false, // Consent handled in onboarding
        keywords: [], // Will be set when editing
        isAIGenerated: false,
      ).then((entry) {
        if (entry != null && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Journal entry created successfully')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Journal Entry'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _headerController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'reflection', child: Text('Reflection')),
                DropdownMenuItem(value: 'gratitude', child: Text('Gratitude')),
                DropdownMenuItem(value: 'goal', child: Text('Goal Setting')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onCreate,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
