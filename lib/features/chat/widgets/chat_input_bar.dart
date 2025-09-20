import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/chat/presentation/widgets/chat_tools_menu.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;
  final Function()? onToolSelected;
  final List<ChatTool>? availableTools;
  final bool isLoading;
  final String? sessionId;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.onToolSelected,
    this.availableTools,
    this.isLoading = false,
    this.sessionId,
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
    
    // Initialize speech-to-text
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (mounted) {
      setState(() {
        // Speech is available
      });
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
    
    // Implement tool-specific actions based on tool ID
    switch (tool.id) {
      case 'journal':
        _handleJournalTool();
        break;
      case 'summary':
        _handleSummaryTool();
        break;
      case 'meditation':
        _handleMeditationTool();
        break;
      case 'breathing':
        _handleBreathingTool();
        break;
      case 'safety':
        _handleSafetyTool();
        break;
      case 'crisis':
        _handleCrisisTool();
        break;
      default:
        // Handle other tools or show generic message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tool.label} tool selected'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
    
    setState(() {
      _showTools = false;
    });
    _toolsAnimationController.reverse();
  }

  void _handleJournalTool() {
    // Navigate to journal creation
    // This would typically open a journal entry dialog or navigate to journal page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal tool selected - Create new journal entry'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSummaryTool() {
    // Generate AI summary of current conversation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Summary tool selected - Generating AI summary'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMeditationTool() {
    // Start meditation session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meditation tool selected - Starting guided meditation'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleBreathingTool() {
    // Start breathing exercise
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Breathing tool selected - Starting breathing exercise'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSafetyTool() {
    // Access safety resources
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safety tool selected - Accessing safety resources'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCrisisTool() {
    // Access crisis resources
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crisis tool selected - Accessing crisis resources'),
        duration: Duration(seconds: 2),
      ),
    );
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

  void _startRecording() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for speech-to-text'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _isListening = true;
    });
    
    HapticFeedback.lightImpact();
    
    // Start listening
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      onSoundLevelChange: (level) {
        // Optional: Handle sound level changes for visual feedback
      },
    );
  }

  void _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isListening = false;
    });
    
    await _speech.stop();
    
    // Process the recognized text
    if (_recognizedText.isNotEmpty) {
      _textController.text = _recognizedText;
      _recognizedText = '';
    }
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final safeArea = MediaQuery.of(context).padding;
    
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
          margin: EdgeInsets.only(
            left: isLargeScreen ? 32 : 16,
            right: isLargeScreen ? 32 : 16,
            top: 8,
            bottom: 8 + safeArea.bottom, // Add bottom safe area padding
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
              // Journal tools menu
              ChatToolsMenu(
                sessionId: widget.sessionId,
                onJournalCreated: () {
                  // Refresh or update UI if needed
                },
              ),
              
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
