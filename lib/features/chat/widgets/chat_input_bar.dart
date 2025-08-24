import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;
  final Function()? onToolSelected;
  final List<ChatTool>? availableTools;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.onToolSelected,
    this.availableTools,
    this.isLoading = false,
  });

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isRecording = false;
  bool _showTools = false;
  late AnimationController _toolsAnimationController;
  late Animation<double> _toolsAnimation;

  @override
  void initState() {
    super.initState();
    _toolsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toolsAnimation = CurvedAnimation(
      parent: _toolsAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _toolsAnimationController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _textController.text.trim();
    if (message.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(message);
      _textController.clear();
      _focusNode.unfocus();
    }
  }

  void _handleToolTap(ChatTool tool) {
    widget.onToolSelected?.call();
    // TODO: Implement tool-specific actions
    setState(() {
      _showTools = false;
    });
    _toolsAnimationController.reverse();
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
    });
    if (_showTools) {
      _toolsAnimationController.forward();
    } else {
      _toolsAnimationController.reverse();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    // TODO: Implement speech-to-text
    HapticFeedback.lightImpact();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    // TODO: Process speech input
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    
    return Column(
      children: [
        // Tools tray (animated)
        if (widget.availableTools != null && widget.availableTools!.isNotEmpty)
          AnimatedBuilder(
            animation: _toolsAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _toolsAnimation,
                child: Container(
                  height: _showTools ? 80 : 0,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.availableTools!.map((tool) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildToolButton(tool),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        
        // Main input bar
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Tools button
              if (widget.availableTools != null && widget.availableTools!.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _showTools ? Icons.close : Icons.add,
                    color: _showTools 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _toggleTools,
                  tooltip: _showTools ? 'Close tools' : 'Open tools',
                ),
              
              // Text input
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: 'Message Mindhearth...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              
              // Microphone button
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording 
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                tooltip: _isRecording ? 'Stop recording' : 'Start recording',
              ),
              
              // Send button
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.send),
                  onPressed: _handleSend,
                  tooltip: 'Send message',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(ChatTool tool) {
    return InkWell(
      onTap: () => _handleToolTap(tool),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tool.icon,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              tool.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTool {
  final IconData icon;
  final String label;
  final String id;
  final Function()? onTap;

  const ChatTool({
    required this.icon,
    required this.label,
    required this.id,
    this.onTap,
  });
}

// Predefined tools
class ChatTools {
  static const List<ChatTool> defaultTools = [
    ChatTool(
      icon: Icons.summarize,
      label: 'Summarize',
      id: 'summarize',
    ),
    ChatTool(
      icon: Icons.translate,
      label: 'Translate',
      id: 'translate',
    ),
    ChatTool(
      icon: Icons.edit,
      label: 'Edit',
      id: 'edit',
    ),
    ChatTool(
      icon: Icons.psychology,
      label: 'Analyze',
      id: 'analyze',
    ),
    ChatTool(
      icon: Icons.question_answer,
      label: 'Explain',
      id: 'explain',
    ),
  ];
}
