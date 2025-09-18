import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Credit validator for checking if operations are allowed
/// Aligned with Mindhearth's principles of transparency and user empowerment
class CreditValidator {
  /// Check if chat operation is allowed
  static bool canPerformChatOperation(BillingStatus? status) {
    if (status == null) {
      appLogger.warning('Billing status is null, allowing chat operation');
      return true; // Allow if status is unknown
    }

    // Check if user has sufficient credits for chat
    const int chatCost = 1; // 1 credit per chat message
    final bool hasEnoughCredits = status.currentBalance >= chatCost;

    appLogger.info('Chat operation check', {
      'currentBalance': status.currentBalance,
      'chatCost': chatCost,
      'canPerform': hasEnoughCredits,
      'status': status.status,
    });

    return hasEnoughCredits;
  }

  /// Check if journal operation is allowed
  static bool canPerformJournalOperation(BillingStatus? status) {
    if (status == null) {
      appLogger.warning('Billing status is null, allowing journal operation');
      return true; // Allow if status is unknown
    }

    // Check if user has sufficient credits for journal operations
    const int journalCost = 2; // 2 credits per journal operation
    final bool hasEnoughCredits = status.currentBalance >= journalCost;

    appLogger.info('Journal operation check', {
      'currentBalance': status.currentBalance,
      'journalCost': journalCost,
      'canPerform': hasEnoughCredits,
      'status': status.status,
    });

    return hasEnoughCredits;
  }

  /// Check if AI summary operation is allowed
  static bool canPerformAISummaryOperation(BillingStatus? status) {
    if (status == null) {
      appLogger.warning('Billing status is null, allowing AI summary operation');
      return true; // Allow if status is unknown
    }

    // Check if user has sufficient credits for AI summary
    const int aiSummaryCost = 3; // 3 credits per AI summary
    final bool hasEnoughCredits = status.currentBalance >= aiSummaryCost;

    appLogger.info('AI summary operation check', {
      'currentBalance': status.currentBalance,
      'aiSummaryCost': aiSummaryCost,
      'canPerform': hasEnoughCredits,
      'status': status.status,
    });

    return hasEnoughCredits;
  }

  /// Get cost for a specific operation
  static int getOperationCost(String operationType) {
    switch (operationType) {
      case 'chat':
        return 1;
      case 'journal':
        return 2;
      case 'ai_summary':
        return 3;
      case 'document_processing':
        return 5;
      default:
        return 1;
    }
  }

  /// Get user-friendly message for insufficient credits
  static String getInsufficientCreditsMessage(String operationType, int currentBalance) {
    final cost = getOperationCost(operationType);
    final needed = cost - currentBalance;

    switch (operationType) {
      case 'chat':
        return 'You need $needed more credit${needed == 1 ? '' : 's'} to send a chat message. '
               'This is completely normal - healing takes time and resources. '
               'You can purchase more credits or wait for your monthly grant.';
      case 'journal':
        return 'You need $needed more credit${needed == 1 ? '' : 's'} to create a journal entry. '
               'Your healing journey is important, and we want to support you. '
               'Consider purchasing more credits or waiting for your monthly grant.';
      case 'ai_summary':
        return 'You need $needed more credit${needed == 1 ? '' : 's'} to generate an AI summary. '
               'AI summaries help you reflect on your progress. '
               'You can purchase more credits or wait for your monthly grant.';
      default:
        return 'You need $needed more credit${needed == 1 ? '' : 's'} to perform this operation. '
               'This is completely normal - healing takes time and resources. '
               'You can purchase more credits or wait for your monthly grant.';
    }
  }

  /// Get trauma-informed encouragement message
  static String getEncouragementMessage(BillingStatus status) {
    switch (status.status) {
      case 'healthy':
        return 'You have a healthy balance of credits. You can continue your healing journey with confidence.';
      case 'low_balance':
        return 'Your balance is getting low, but this is completely normal. Healing takes time and resources. '
               'You can purchase more credits when you\'re ready, or wait for your monthly grant.';
      case 'insufficient':
        return 'You don\'t have enough credits right now, but this is okay. '
               'Everyone\'s healing journey is different, and we\'re here to support you. '
               'You can purchase more credits or wait for your monthly grant.';
      default:
        return 'We\'re here to support you on your healing journey. '
               'If you have any questions about your account, please don\'t hesitate to contact support.';
    }
  }
}
