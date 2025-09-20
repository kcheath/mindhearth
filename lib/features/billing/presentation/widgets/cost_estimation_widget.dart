import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';
import 'package:mindhearth/features/billing/domain/services/document_cost_service.dart';
import 'package:mindhearth/features/billing/domain/services/session_time_service.dart';
import 'package:mindhearth/features/billing/domain/services/ai_summary_service.dart';

/// Cost estimation widget for displaying estimated costs
class CostEstimationWidget extends ConsumerWidget {
  final String type;
  final int? sizeBytes;
  final int? durationSeconds;
  final String? sessionId;

  const CostEstimationWidget({
    super.key,
    required this.type,
    this.sizeBytes,
    this.durationSeconds,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForType(type),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTitleForType(type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCostEstimation(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCostEstimation(BuildContext context, WidgetRef ref) {
    switch (type) {
      case 'document':
        return _buildDocumentCostEstimation(context, ref);
      case 'session_time':
        return _buildSessionTimeCostEstimation(context, ref);
      case 'ai_summary':
        return _buildAISummaryCostEstimation(context, ref);
      default:
        return const Text('Unknown cost type');
    }
  }

  Widget _buildDocumentCostEstimation(BuildContext context, WidgetRef ref) {
    if (sizeBytes == null) return const Text('Size not specified');

    return FutureBuilder<CostEstimation>(
      future: ref.read(documentCostServiceProvider).estimateDocumentCost(sizeBytes!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final estimation = snapshot.data!;
        final sizeMB = sizeBytes! / (1024 * 1024);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCostRow('File Size', '${sizeMB.toStringAsFixed(2)} MB'),
            _buildCostRow('Estimated Cost', '${estimation.estimatedCost} credits'),
            _buildCostRow('Currency', estimation.currency),
            if (estimation.notes != null)
              _buildCostRow('Notes', estimation.notes!),
          ],
        );
      },
    );
  }

  Widget _buildSessionTimeCostEstimation(BuildContext context, WidgetRef ref) {
    if (durationSeconds == null) return const Text('Duration not specified');

    return FutureBuilder<CostEstimation>(
      future: ref.read(sessionTimeServiceProvider).estimateSessionTimeCost(durationSeconds!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final estimation = snapshot.data!;
        final minutes = durationSeconds! / 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCostRow('Duration', '${minutes.toStringAsFixed(2)} minutes'),
            _buildCostRow('Estimated Cost', '${estimation.estimatedCost} credits'),
            _buildCostRow('Currency', estimation.currency),
            if (estimation.notes != null)
              _buildCostRow('Notes', estimation.notes!),
          ],
        );
      },
    );
  }

  Widget _buildAISummaryCostEstimation(BuildContext context, WidgetRef ref) {
    return FutureBuilder<CostEstimation>(
      future: ref.read(aiSummaryServiceProvider).estimateAISummaryCost(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final estimation = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCostRow('Service', 'AI Summary Generation'),
            _buildCostRow('Estimated Cost', '${estimation.estimatedCost} credits'),
            _buildCostRow('Currency', estimation.currency),
            if (estimation.notes != null)
              _buildCostRow('Notes', estimation.notes!),
          ],
        );
      },
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'document':
        return Icons.description;
      case 'session_time':
        return Icons.timer;
      case 'ai_summary':
        return Icons.auto_awesome;
      default:
        return Icons.help;
    }
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'document':
        return 'Document Processing Cost';
      case 'session_time':
        return 'Session Time Cost';
      case 'ai_summary':
        return 'AI Summary Cost';
      default:
        return 'Cost Estimation';
    }
  }
}

/// Cost estimation dialog
class CostEstimationDialog extends ConsumerWidget {
  final String type;
  final int? sizeBytes;
  final int? durationSeconds;
  final String? sessionId;
  final VoidCallback? onConfirm;

  const CostEstimationDialog({
    super.key,
    required this.type,
    this.sizeBytes,
    this.durationSeconds,
    this.sessionId,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(_getTitleForType(type)),
      content: SizedBox(
        width: 300,
        child: CostEstimationWidget(
          type: type,
          sizeBytes: sizeBytes,
          durationSeconds: durationSeconds,
          sessionId: sessionId,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'document':
        return 'Document Processing Cost';
      case 'session_time':
        return 'Session Time Cost';
      case 'ai_summary':
        return 'AI Summary Cost';
      default:
        return 'Cost Estimation';
    }
  }
}

/// Cost estimation button
class CostEstimationButton extends ConsumerWidget {
  final String type;
  final int? sizeBytes;
  final int? durationSeconds;
  final String? sessionId;
  final VoidCallback? onConfirm;

  const CostEstimationButton({
    super.key,
    required this.type,
    this.sizeBytes,
    this.durationSeconds,
    this.sessionId,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _showCostEstimationDialog(context, ref),
      icon: const Icon(Icons.calculate),
      label: const Text('Estimate Cost'),
    );
  }

  void _showCostEstimationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CostEstimationDialog(
        type: type,
        sizeBytes: sizeBytes,
        durationSeconds: durationSeconds,
        sessionId: sessionId,
        onConfirm: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
      ),
    );
  }
}
