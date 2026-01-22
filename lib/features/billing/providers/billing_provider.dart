import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/billing_service.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_package.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Billing state class for managing billing-related state
class BillingState {
  final int balance;
  final BillingStatus? billingStatus;
  final List<LedgerEntry> ledgerEntries;
  final List<Purchase> purchases;
  final bool isLoading;
  final String? error;
  final bool hasMoreLedger;
  final bool hasMorePurchases;

  const BillingState({
    this.balance = 0,
    this.billingStatus,
    this.ledgerEntries = const [],
    this.purchases = const [],
    this.isLoading = false,
    this.error,
    this.hasMoreLedger = true,
    this.hasMorePurchases = true,
  });

  BillingState copyWith({
    int? balance,
    BillingStatus? billingStatus,
    List<LedgerEntry>? ledgerEntries,
    List<Purchase>? purchases,
    bool? isLoading,
    String? error,
    bool? hasMoreLedger,
    bool? hasMorePurchases,
  }) {
    return BillingState(
      balance: balance ?? this.balance,
      billingStatus: billingStatus ?? this.billingStatus,
      ledgerEntries: ledgerEntries ?? this.ledgerEntries,
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMoreLedger: hasMoreLedger ?? this.hasMoreLedger,
      hasMorePurchases: hasMorePurchases ?? this.hasMorePurchases,
    );
  }
}

/// Billing notifier for managing billing state and operations
class BillingNotifier extends StateNotifier<BillingState> {
  final BillingService _billingService;

  BillingNotifier(this._billingService) : super(const BillingState());

  /// Load all billing data
  Future<void> loadBillingData() async {
    await Future.wait([
      loadBillingStatus(), // This includes balance information
      loadLedger(),
      loadPurchases(),
    ]);
  }

  /// Load user balance
  Future<void> loadBalance() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _billingService.getBalance();
      
      response.when(
        success: (balance, statusCode) {
          state = state.copyWith(
            balance: balance,
            isLoading: false,
          );
          appLogger.info('Balance loaded successfully', {'balance': balance});
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load balance', {
            'error': message,
            'statusCode': statusCode,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading balance', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load balance',
      );
    }
  }

  /// Load billing status
  Future<void> loadBillingStatus() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _billingService.getBillingStatus();
      
      response.when(
        success: (billingStatus, statusCode) {
          state = state.copyWith(
            billingStatus: billingStatus,
            balance: billingStatus.currentBalance, // Set balance from billing status
            isLoading: false,
          );
          appLogger.info('Billing status loaded successfully', {
            'status': billingStatus.status,
            'balance': billingStatus.currentBalance,
          });
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load billing status', {
            'error': message,
            'statusCode': statusCode,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading billing status', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load billing status',
      );
    }
  }

  /// Load credit ledger
  Future<void> loadLedger({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(ledgerEntries: [], hasMoreLedger: true);
      }
      
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _billingService.getLedger(
        limit: 50,
        before: state.ledgerEntries.isNotEmpty 
            ? state.ledgerEntries.last.createdAt 
            : null,
      );
      
      response.when(
        success: (newEntries, statusCode) {
          final updatedEntries = refresh 
              ? newEntries 
              : [...state.ledgerEntries, ...newEntries];
          
          state = state.copyWith(
            ledgerEntries: updatedEntries,
            hasMoreLedger: newEntries.length == 50,
            isLoading: false,
          );
          appLogger.info('Credit ledger loaded successfully', {
            'entryCount': newEntries.length,
            'totalEntries': updatedEntries.length,
          });
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load credit ledger', {
            'error': message,
            'statusCode': statusCode,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading credit ledger', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load credit ledger',
      );
    }
  }

  /// Load purchase history
  Future<void> loadPurchases({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(purchases: [], hasMorePurchases: true);
      }
      
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _billingService.getPurchaseHistory(
        limit: 50,
        before: state.purchases.isNotEmpty 
            ? state.purchases.last.createdAt 
            : null,
      );
      
      response.when(
        success: (newPurchases, statusCode) {
          final updatedPurchases = refresh 
              ? newPurchases 
              : [...state.purchases, ...newPurchases];
          
          state = state.copyWith(
            purchases: updatedPurchases,
            hasMorePurchases: newPurchases.length == 50,
            isLoading: false,
          );
          appLogger.info('Purchase history loaded successfully', {
            'purchaseCount': newPurchases.length,
            'totalPurchases': updatedPurchases.length,
          });
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load purchase history', {
            'error': message,
            'statusCode': statusCode,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading purchase history', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load purchase history',
      );
    }
  }

  /// Check if an operation is allowed
  Future<bool> checkOperation(String operationType) async {
    try {
      final response = await _billingService.checkOperation(operationType);
      
      return response.when(
        success: (data, statusCode) => data['allowed'] as bool? ?? false,
        error: (message, statusCode, errors) {
          appLogger.error('Failed to check operation', {
            'error': message,
            'operationType': operationType,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error checking operation', {
        'error': e.toString(),
        'operationType': operationType,
      });
      return false;
    }
  }

  /// Gift credits to another user
  Future<bool> giftCredits({
    required String recipientUserId,
    required int amount,
    String? message,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _billingService.giftCredits(
        recipientUserId: recipientUserId,
        amount: amount,
        message: message,
      );
      
      return response.when(
        success: (ledgerEntry, statusCode) {
          // Add the gift transaction to ledger
          final updatedEntries = [ledgerEntry, ...state.ledgerEntries];
          state = state.copyWith(
            ledgerEntries: updatedEntries,
            balance: state.balance - amount, // Update balance
            isLoading: false,
          );
          appLogger.info('Credits gifted successfully', {
            'recipientUserId': recipientUserId,
            'amount': amount,
            'ledgerEntryId': ledgerEntry.id,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to gift credits', {
            'error': message,
            'recipientUserId': recipientUserId,
            'amount': amount,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error gifting credits', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to gift credits',
      );
      return false;
    }
  }

  /// Purchase credits
  Future<bool> purchaseCredits({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _billingService.purchaseCredits(
        packageId: packageId,
        paymentMethod: paymentMethod,
        paymentData: paymentData,
      );
      
      return response.when(
        success: (purchase, statusCode) {
          state = state.copyWith(isLoading: false);
          appLogger.info('Credits purchased successfully', {
            'purchaseId': purchase.id,
            'packageId': packageId,
          });
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to purchase credits', {
            'error': message,
            'packageId': packageId,
          });
          return false;
        },
      );
    } catch (e) {
      appLogger.error('Error purchasing credits', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to purchase credits',
      );
      return false;
    }
  }

  /// Refresh all billing data
  Future<void> refreshAll() async {
    await Future.wait([
      loadBalance(),
      loadBillingStatus(),
      loadLedger(refresh: true),
      loadPurchases(refresh: true),
    ]);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get available credit packages
  Future<List<CreditPackage>> getCreditPackages() async {
    try {
      appLogger.info('Loading credit packages from backend');
      
      final response = await _billingService.getCreditPackages();
      
      return response.when(
        success: (packages, statusCode) {
          appLogger.info('Credit packages loaded successfully', {
            'count': packages.length,
          });
          return packages;
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to load credit packages', {
            'error': message,
            'statusCode': statusCode,
          });
          throw Exception('Failed to load credit packages: $message');
        },
      );
    } catch (e) {
      appLogger.error('Error loading credit packages', {'error': e.toString()});
      rethrow;
    }
  }
}

/// Riverpod provider for BillingService
final billingServiceProvider = Provider<BillingService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return BillingService(apiService);
});

/// Riverpod provider for BillingNotifier
final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  final billingService = ref.read(billingServiceProvider);
  return BillingNotifier(billingService);
});

/// Convenience providers for specific billing data
final balanceProvider = Provider<int>((ref) {
  return ref.watch(billingProvider).balance;
});

final billingStatusProvider = Provider<BillingStatus?>((ref) {
  return ref.watch(billingProvider).billingStatus;
});

final ledgerEntriesProvider = Provider<List<LedgerEntry>>((ref) {
  return ref.watch(billingProvider).ledgerEntries;
});

final purchasesProvider = Provider<List<Purchase>>((ref) {
  return ref.watch(billingProvider).purchases;
});

final billingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(billingProvider).isLoading;
});

final billingErrorProvider = Provider<String?>((ref) {
  return ref.watch(billingProvider).error;
});
