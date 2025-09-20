import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';

/// Reusable chat app bar component
class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? sessionName;
  final VoidCallback? onShowHistory;
  final VoidCallback? onShowSessionInfo;
  final VoidCallback? onStartNewSession;

  const ChatAppBar({
    super.key,
    this.sessionName,
    this.onShowHistory,
    this.onShowSessionInfo,
    this.onStartNewSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final currentSession = chatState.currentSession;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentSession?.name ?? 'Chat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (currentSession != null)
            Text(
              '${chatState.messages.length} messages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/chat'),
        tooltip: 'Back to Chat',
      ),
      actions: [
        if (onShowSessionInfo != null)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onShowSessionInfo,
            tooltip: 'Session Information',
          ),
        if (onShowHistory != null)
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: onShowHistory,
            tooltip: 'Session History',
          ),
        if (onStartNewSession != null)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onStartNewSession,
            tooltip: 'Start New Session',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
