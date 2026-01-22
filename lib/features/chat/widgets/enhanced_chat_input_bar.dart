import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/chat/presentation/widgets/chat_tools_menu.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Enhanced chat input bar with RAG toggle and improved functionality
class EnhancedChatInputBar extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;
  final Function()? onToolSelected;
  final List<ChatTool>? availableTools;
  final bool isLoading;
  final String? sessionId;
  final bool ragEnabled;
  final Function(bool)? onRagToggle;

  const EnhancedChatInputBar({
    super.key,
    required this.onSendMessage,
    this.onToolSelected,
    this.availableTools,
    this.isLoading = false,
    this.sessionId,
    this.ragEnabled = true,
    this.onRagToggle,
  });

  @override
  ConsumerState<EnhancedChatInputBar> createState() => _EnhancedChatInputBarState();
}

class _EnhancedChatInputBarState extends ConsumerState<EnhancedChatInputBar>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isRecording = false;
  bool _showTools = false;
  late AnimationController _toolsAnimationController;
  late Animation<double> _toolsAnimation;
  
  // Speech-to-text functionality
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

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
    
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize();
      if (mounted) {
        setState(() {
          // Speech is available
        });
      }
    } catch (e) {
      // Handle speech-to-text initialization errors gracefully
      print('Speech-to-text initialization failed: $e');
      // Continue without speech functionality
    }
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
    _toggleTools();
  }

  void _toggleTools() {
    setState(() {
      _showTools = !_showTools;
      if (_showTools) {
        _toolsAnimationController.forward();
      } else {
        _toolsAnimationController.reverse();
      }
    });
  }

  void _startListening() async {
    if (!_isListening) {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice input'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _textController.text = _recognizedText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // RAG Toggle
          if (widget.onRagToggle != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: widget.ragEnabled 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Use personal context',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Switch(
                    value: widget.ragEnabled,
                    onChanged: widget.onRagToggle,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          
          // Input Row
          Row(
            children: [
              // Text Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Voice Input Button
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _isListening ? _stopListening : _startListening,
                            tooltip: _isListening ? 'Stop recording' : 'Start recording',
                          ),
                          
                          // Send Button
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: _textController.text.trim().isNotEmpty
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _textController.text.trim().isNotEmpty && !widget.isLoading
                                ? _handleSend
                                : null,
                            tooltip: 'Send message',
                          ),
                        ],
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                    onSubmitted: (value) => _handleSend(),
                  ),
                ),
              ),
              
              // Tools Button
              if (widget.availableTools != null && widget.availableTools!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: Icon(
                      _showTools ? Icons.close : Icons.more_horiz,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _toggleTools,
                    tooltip: _showTools ? 'Hide tools' : 'Show tools',
                  ),
                ),
            ],
          ),
          
          // Tools Menu
          if (widget.availableTools != null && widget.availableTools!.isNotEmpty)
            SizeTransition(
              sizeFactor: _toolsAnimation,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: ChatToolsMenu(
                  tools: widget.availableTools!,
                  onToolSelected: _handleToolTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}





