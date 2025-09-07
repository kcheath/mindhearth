import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/core/providers/session_provider.dart';
import 'package:mindhearth/core/models/session_state.dart';

class SessionsPage extends ConsumerStatefulWidget {
  const SessionsPage({super.key});

  @override
  ConsumerState<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends ConsumerState<SessionsPage> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    // Load sessions when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionNotifierProvider.notifier).loadSessions();
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

  void _onSessionTap(Session session) {
    // Navigate to chat with the selected session
    ref.read(sessionNotifierProvider.notifier).setCurrentSession(session);
    context.go('/chat');
  }

  void _onRefresh() {
    ref.read(sessionNotifierProvider.notifier).refreshSessions();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionStateProvider);
    
    return AdaptiveNavigation(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
            ),
          ],
        ),
        body: _buildBody(context, sessionState),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Create a new session and navigate to chat
            ref.read(sessionNotifierProvider.notifier).createSession(
              name: 'New Conversation',
              sessionType: 'conversation',
              purpose: 'AI-assisted therapy conversation',
            ).then((session) {
              if (session != null && mounted) {
                context.go('/chat');
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionState sessionState) {
    if (sessionState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (sessionState.error != null) {
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
              'Failed to load sessions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              sessionState.error!,
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

    if (!sessionState.hasSessions) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No Sessions Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start a new conversation to see your session history here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(sessionNotifierProvider.notifier).createSession(
                  name: 'New Conversation',
                  sessionType: 'conversation',
                  purpose: 'AI-assisted therapy conversation',
                ).then((session) {
                  if (session != null && mounted) {
                    context.go('/chat');
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Start New Session'),
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
        itemCount: sessionState.sessions.length,
        itemBuilder: (context, index) {
          final session = sessionState.sessions[index];
          return _buildSessionCard(context, session);
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.chat_bubble_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          session.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.purpose ?? 'AI-assisted therapy conversation',
              style: Theme.of(context).textTheme.bodySmall,
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
                  _formatDate(session.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (session.messageCount > 0) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.message,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.messageCount} messages',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _onSessionTap(session),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
