import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/journal/presentation/widgets/create_journal_entry_dialog.dart';
import 'package:mindhearth/features/journal/providers/journal_provider.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';

class ChatToolsMenu extends ConsumerWidget {
  final String? sessionId;
  final VoidCallback? onJournalCreated;

  const ChatToolsMenu({
    Key? key,
    this.sessionId,
    this.onJournalCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.tune),
      tooltip: 'Tools',
      onSelected: (value) => _handleMenuSelection(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'create_journal',
          child: ListTile(
            leading: Icon(Icons.book),
            title: Text('Create Journal Entry'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'ai_summary',
          child: ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text('AI Summary from Chat'),
            subtitle: Text('Create AI summary of current conversation'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'create_journal':
        _showCreateJournalDialog(context, ref);
        break;
      case 'ai_summary':
        _createAISummary(context, ref);
        break;
    }
  }

  void _showCreateJournalDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateJournalEntryDialog(
        sessionId: sessionId,
        onCreated: (entry) {
          if (onJournalCreated != null) {
            onJournalCreated!();
          }
        },
      ),
    );
  }

  void _createAISummary(BuildContext context, WidgetRef ref) async {
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active session to create summary from'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Creating AI journal summary...'),
          ],
        ),
      ),
    );

    try {
      final entry = await ref.read(journalProvider.notifier).createAIJournalSummary(
        sessionId: sessionId!,
        entryType: 'ai_summary',
        tags: ['ai_generated', 'session_summary'],
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (entry != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI summary of current conversation created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          if (onJournalCreated != null) {
            onJournalCreated!();
          }
        } else {
          final error = ref.read(journalProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to create AI journal summary'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
