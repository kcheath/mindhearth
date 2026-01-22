import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';

/// Enhanced chat message bubble with RAG support and source display
class EnhancedChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final DateTime? timestamp;
  final bool isLoading;
  final VoidCallback? onCopy;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const EnhancedChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.isLoading = false,
    this.onCopy,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // AI Avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/images/mindhearth_logo.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: isLoading
                      ? _buildLoadingIndicator(context)
                      : _buildMessageContent(context),
                ),
                
                // RAG Sources (only for AI messages)
                if (!isUser && !isLoading && _hasRAGSources())
                  _buildRAGSources(context),
                
                // Timestamp and actions
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: isUser 
                        ? MainAxisAlignment.end 
                        : MainAxisAlignment.start,
                    children: [
                      // Timestamp
                      if (timestamp != null)
                        Text(
                          _formatTimestamp(timestamp!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      
                      // Actions (only for AI messages)
                      if (!isUser && !isLoading) ...[
                        const SizedBox(width: 8),
                        _buildActionButtons(context),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            // User Avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasRAGSources() {
    final sources = message.metadata?['sources'] as List<dynamic>?;
    return sources != null && sources.isNotEmpty;
  }

  Widget _buildRAGSources(BuildContext context) {
    final sources = message.metadata?['sources'] as List<dynamic>? ?? [];
    final ragMetadata = message.metadata?['rag_metadata'] as Map<String, dynamic>?;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: RAGSourcesWidget(
        sources: sources.map((s) => SourceDocument.fromJson(s)).toList(),
        ragMetadata: ragMetadata != null ? RAGMetadata.fromJson(ragMetadata) : null,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Mindhearth is thinking...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return SelectableText(
      message.content,
      style: TextStyle(
        color: isUser
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy button
        _buildActionButton(
          context,
          Icons.copy,
          'Copy',
          () {
            Clipboard.setData(ClipboardData(text: message.content));
            onCopy?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        
        // Save button
        _buildActionButton(
          context,
          Icons.bookmark_border,
          'Save',
          () {
            onSave?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message saved'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        
        // Share button
        _buildActionButton(
          context,
          Icons.share,
          'Share',
          () {
            onShare?.call();
            _shareMessage();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _shareMessage() {
    Share.share(
      message.content,
      subject: 'Chat Message from Mindhearth',
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Widget for displaying RAG sources
class RAGSourcesWidget extends StatelessWidget {
  final List<SourceDocument> sources;
  final RAGMetadata? ragMetadata;
  
  const RAGSourcesWidget({
    super.key,
    required this.sources,
    this.ragMetadata,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RAG Header
          Row(
            children: [
              Icon(
                Icons.search,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Sources (${sources.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (ragMetadata != null)
                Text(
                  '${ragMetadata?.contextRetrieved ?? 0}/${ragMetadata?.totalSources ?? 0}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Sources List
          ...sources.map((source) => SourceDocumentTile(
            source: source,
          )).toList(),
        ],
      ),
    );
  }
}

/// Widget for displaying individual source documents
class SourceDocumentTile extends StatelessWidget {
  final SourceDocument source;
  
  const SourceDocumentTile({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Source Type Icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getIconForType(source.type),
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Source Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.content.length > 100 
                      ? '${source.content.substring(0, 100)}...' 
                      : source.content,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      source.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(source.relevanceScore * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'journal': return Icons.book;
      case 'chat': return Icons.chat;
      case 'document': return Icons.description;
      case 'profile': return Icons.person;
      default: return Icons.article;
    }
  }
}
