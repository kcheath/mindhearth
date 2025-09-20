import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';
import 'package:mindhearth/features/billing/domain/providers/session_question_provider.dart';
import 'package:mindhearth/features/billing/providers/billing_provider.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';
import 'package:mindhearth/core/services/debug_billing_service.dart';
import 'package:mindhearth/core/utils/logger.dart';

class CreditUsageDebugScreen extends ConsumerStatefulWidget {
  const CreditUsageDebugScreen({super.key});

  @override
  ConsumerState<CreditUsageDebugScreen> createState() => _CreditUsageDebugScreenState();
}

class _CreditUsageDebugScreenState extends ConsumerState<CreditUsageDebugScreen> {
  // State management
  bool _isLoading = false;
  int? _currentBalance;
  List<LedgerEntry> _recentTransactions = [];
  
  // Controllers for input fields
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _fileSizeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _creditController.dispose();
    _questionController.dispose();
    _fileSizeController.dispose();
    super.dispose();
  }

  // Load all current data
  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    try {
      final billingService = ref.read(billingServiceProvider);
      final balanceResponse = await billingService.getBalance();
      final ledgerResponse = await billingService.getLedger(limit: 10);
      
      // Refresh question counts from backend
      final sessionQuestionNotifier = ref.read(sessionQuestionProvider.notifier);
      await sessionQuestionNotifier.refreshQuestionCounts();
      
      setState(() {
        _currentBalance = balanceResponse.when(
          success: (data, message) => data,
          error: (message, statusCode, errors) => 0,
        );
        _recentTransactions = ledgerResponse.when(
          success: (data, message) => data,
          error: (message, statusCode, errors) => [],
        );
      });
    } catch (e) {
      appLogger.error('Failed to load current data', e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Refresh all data
  Future<void> _refreshAllData() async {
    await _loadCurrentData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully')),
      );
    }
  }

  // Question-based billing methods
  Future<void> _addQuestions() async {
    final questions = int.tryParse(_questionController.text);
    if (questions == null || questions <= 0) return;
    
    try {
      final sessionQuestionNotifier = ref.read(sessionQuestionProvider.notifier);
      final chatState = ref.read(chatProvider);
      
      appLogger.info('Adding questions to debug screen', {
        'questions': questions,
        'currentSessionId': chatState.currentSessionId,
      });
      
      // Use current session ID or create a debug session ID
      final sessionId = chatState.currentSessionId ?? 'debug-session-${DateTime.now().millisecondsSinceEpoch}';
      
      appLogger.info('Using session ID for questions', {
        'sessionId': sessionId,
        'isDebugSession': chatState.currentSessionId == null,
      });
      
      await sessionQuestionNotifier.addQuestions(questions, sessionId: sessionId);
      
      // Get the updated state after adding questions
      final updatedState = ref.read(sessionQuestionProvider);
      appLogger.info('Session question state after adding questions', {
        'sessionQuestions': updatedState.sessionQuestions,
        'globalTotalQuestions': updatedState.globalTotalQuestions,
        'questionsPerCredit': updatedState.questionsPerCredit,
      });
      
      await _loadCurrentData();
      _questionController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $questions questions to ${chatState.currentSessionId != null ? 'current session' : 'debug session'}')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to add questions', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _resetSession() async {
    try {
      // Simulate session reset by refreshing data
      await _loadCurrentData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session reset successfully')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to reset session', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _refreshSessionData() async {
    try {
      // Simulate session data refresh
      await _loadCurrentData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session data refreshed')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to refresh session data', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Document processing methods
  Future<void> _estimateDocumentCost() async {
    final sizeBytes = int.tryParse(_fileSizeController.text);
    if (sizeBytes == null || sizeBytes <= 0) return;
    
    try {
      // Simulate cost estimation (1 credit per MB)
      final cost = (sizeBytes / (1024 * 1024)).ceil();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estimated cost: $cost credits')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to estimate document cost', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _simulateDocumentProcessing() async {
    final sizeBytes = int.tryParse(_fileSizeController.text);
    if (sizeBytes == null || sizeBytes <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid file size')),
        );
      }
      return;
    }
    
    try {
      // Simulate document processing
      await _loadCurrentData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document processing simulated')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to simulate document processing', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _confirmDocumentProcessing() async {
    final sizeBytes = int.tryParse(_fileSizeController.text);
    if (sizeBytes == null || sizeBytes <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid file size')),
        );
      }
      return;
    }
    
    try {
      // Simulate document processing confirmation
      await _loadCurrentData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document processing confirmed')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to confirm document processing', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // AI Summary methods
  Future<Map<String, dynamic>> _getAISummaryConfig() async {
    try {
      // Simulate AI summary config
      return {
        'ai_summary_credits': 1,
        'description': 'AI Summary Generation',
        'configurable': true,
      };
    } catch (e) {
      appLogger.error('Failed to get AI summary config', e);
      return {};
    }
  }

  Future<void> _simulateAISummary() async {
    try {
      final chatState = ref.read(chatProvider);
      
      if (chatState.currentSessionId != null) {
        // Simulate AI summary generation
        await _loadCurrentData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI Summary generated')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active session found')),
          );
        }
      }
    } catch (e) {
      appLogger.error('Failed to simulate AI summary', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _refreshAISummaryConfig() async {
    try {
      await _getAISummaryConfig();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Summary config refreshed')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to refresh AI summary config', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Transaction history methods
  Future<void> _refreshTransactions() async {
    try {
      final billingService = ref.read(billingServiceProvider);
      final ledgerResponse = await billingService.getLedger(limit: 20);
      
      setState(() {
        _recentTransactions = ledgerResponse.when(
          success: (data, message) => data,
          error: (message, statusCode, errors) => [],
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transactions refreshed')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to refresh transactions', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Utility methods
  Future<void> _setCredits() async {
    final credits = int.tryParse(_creditController.text);
    if (credits == null) return;
    
    try {
      final debugBillingService = DebugBillingService(ref.read(apiServiceProvider));
      final response = await debugBillingService.topUpCredits(credits: credits);
      
      if (response.when(
        success: (data, message) => true,
        error: (message, statusCode, errors) => false,
      )) {
        await _loadCurrentData();
        _creditController.clear();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Credits set to $credits')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to set credits')),
          );
        }
      }
    } catch (e) {
      appLogger.error('Failed to set credits', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _resetLedger() async {
    try {
      final debugBillingService = DebugBillingService(ref.read(apiServiceProvider));
      final response = await debugBillingService.resetBillingData();
      
      if (response.when(
        success: (data, message) => true,
        error: (message, statusCode, errors) => false,
      )) {
        await _loadCurrentData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ledger reset successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reset ledger')),
          );
        }
      }
    } catch (e) {
      appLogger.error('Failed to reset ledger', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _copyUserId() async {
    try {
      final userResponse = await ref.read(apiServiceProvider).getCurrentUser();
      final userId = userResponse.when(
        success: (data, message) => data['id'] as String?,
        error: (message, statusCode, errors) => null,
      );
      
      if (userId != null) {
        await Clipboard.setData(ClipboardData(text: userId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID copied to clipboard')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get user ID')),
          );
        }
      }
    } catch (e) {
      appLogger.error('Failed to copy user ID', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportDebugData() async {
    try {
      final billingService = ref.read(billingServiceProvider);
      final balanceResponse = await billingService.getBalance();
      final ledgerResponse = await billingService.getLedger(limit: 50);
      final statusResponse = await billingService.getBillingStatus();
      
      final debugData = {
        'timestamp': DateTime.now().toIso8601String(),
        'balance': balanceResponse.when(
          success: (data, message) => data,
          error: (message, statusCode, errors) => 0,
        ),
        'status': statusResponse.when(
          success: (data, message) => data.toJson(),
          error: (message, statusCode, errors) => {},
        ),
        'transactions': ledgerResponse.when(
          success: (data, message) => data.map((e) => e.toJson()).toList(),
          error: (message, statusCode, errors) => [],
        ),
      };
      
      await Clipboard.setData(ClipboardData(text: debugData.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debug data copied to clipboard')),
        );
      }
    } catch (e) {
      appLogger.error('Failed to export debug data', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'low_warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      case 'blocked':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Usage Debug'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCreditMonitoringSection(),
                  const SizedBox(height: 16),
                  _buildQuestionBillingSection(),
                  const SizedBox(height: 16),
                  _buildDocumentProcessingSection(),
                  const SizedBox(height: 16),
                  _buildAISummarySection(),
                  const SizedBox(height: 16),
                  _buildTransactionHistorySection(),
                  const SizedBox(height: 16),
                  _buildQuickActionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCreditMonitoringSection() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-Time Credit Monitoring',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Current Balance Display
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Balance: ${_currentBalance ?? 'Loading...'} credits',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Credit Status Indicator
            Consumer(
              builder: (context, ref, child) {
                final billingState = ref.watch(billingProvider);
                final status = billingState.billingStatus?.status ?? 'unknown';
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Status: ${status.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Refresh Button
            ElevatedButton.icon(
              onPressed: _refreshAllData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh All Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionBillingSection() {
    return Consumer(
      builder: (context, ref, child) {
        final sessionQuestionState = ref.watch(sessionQuestionProvider);
        
        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question-Based Billing Debug',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Current Session Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Questions: ${sessionQuestionState.sessionQuestions.values.fold(0, (sum, count) => sum + count)}'),
                      Text('Global Questions: ${sessionQuestionState.globalTotalQuestions}'),
                      Text('Questions per Credit: ${sessionQuestionState.questionsPerCredit}'),
                      Text('Credits Used: ${sessionQuestionState.creditsUsed}'),
                      Text('Questions Remaining: ${sessionQuestionState.questionsRemainingInCurrentCredit}'),
                      Text('Status: ${sessionQuestionState.isLoading ? 'Loading' : 'Ready'}'),
                      if (sessionQuestionState.sessionQuestions.isNotEmpty)
                        Text('Sessions: ${sessionQuestionState.sessionQuestions.keys.join(', ')}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Add Questions Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Questions to Add',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addQuestions,
                      child: const Text('Add Questions'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Quick Add Buttons
                Wrap(
                  spacing: 8,
                  children: [1, 5, 10, 15, 20].map((questions) => ElevatedButton(
                    onPressed: () {
                      _questionController.text = questions.toString();
                      _addQuestions();
                    },
                    child: Text('+$questions'),
                  )).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Session Management
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetSession,
                      icon: const Icon(Icons.clear),
                      label: const Text('Reset Session'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _refreshSessionData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentProcessingSection() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Processing Debug',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // File Size Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fileSizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'File Size (bytes)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _estimateDocumentCost,
                  child: const Text('Estimate Cost'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Quick File Size Buttons
            Wrap(
              spacing: 8,
              children: [
                '1024', '1048576', '10485760', '104857600' // 1KB, 1MB, 10MB, 100MB
              ].map((size) => ElevatedButton(
                onPressed: () {
                  _fileSizeController.text = size;
                  _estimateDocumentCost();
                },
                child: Text('${(int.parse(size) / 1024 / 1024).toStringAsFixed(1)}MB'),
              )).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Document Processing Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _simulateDocumentProcessing,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Simulate Processing'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: _confirmDocumentProcessing,
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm Processing'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISummarySection() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Summary Debug',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // AI Summary Config Display
            FutureBuilder<Map<String, dynamic>>(
              future: _getAISummaryConfig(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final config = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Credits per Summary: ${config['ai_summary_credits']}'),
                        Text('Description: ${config['description']}'),
                        Text('Configurable: ${config['configurable']}'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // AI Summary Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _simulateAISummary,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Simulate AI Summary'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshAISummaryConfig,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Config'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistorySection() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Recent Transactions List
            if (_recentTransactions.isEmpty)
              const Text('No recent transactions')
            else
              ..._recentTransactions.take(10).map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      entry.delta > 0 ? Icons.add : Icons.remove,
                      color: entry.delta > 0 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.type.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (entry.notes != null)
                            Text(
                              entry.notes!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.delta > 0 ? '+' : ''}${entry.delta}',
                      style: TextStyle(
                        color: entry.delta > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
            
            const SizedBox(height: 16),
            
            // Refresh Transactions Button
            ElevatedButton.icon(
              onPressed: _refreshTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Transactions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Credit Management
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _creditController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Credits to Set',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _setCredits,
                  icon: const Icon(Icons.add),
                  label: const Text('Set Credits'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Development Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetLedger,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Ledger'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _copyUserId,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy User ID'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Export Data
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportDebugData,
                icon: const Icon(Icons.download),
                label: const Text('Export Debug Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}