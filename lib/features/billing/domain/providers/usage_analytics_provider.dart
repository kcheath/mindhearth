import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/providers/usecase_providers.dart';
import 'package:mindhearth/core/domain/usecases/usage_analytics_usecases.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// Usage analytics state
class UsageAnalyticsState {
  final bool isLoading;
  final String? error;
  final UsageAnalytics? analytics;
  final int periodDays;

  const UsageAnalyticsState({
    this.isLoading = false,
    this.error,
    this.analytics,
    this.periodDays = 30,
  });

  UsageAnalyticsState copyWith({
    bool? isLoading,
    String? error,
    UsageAnalytics? analytics,
    int? periodDays,
  }) {
    return UsageAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      analytics: analytics ?? this.analytics,
      periodDays: periodDays ?? this.periodDays,
    );
  }
}

/// Usage analytics notifier
class UsageAnalyticsNotifier extends StateNotifier<UsageAnalyticsState> {
  final ApiService _apiService;
  final GetUsageAnalyticsUseCase _getUsageAnalyticsUseCase;

  UsageAnalyticsNotifier({
    required ApiService apiService,
    required GetUsageAnalyticsUseCase getUsageAnalyticsUseCase,
  }) : _apiService = apiService,
       _getUsageAnalyticsUseCase = getUsageAnalyticsUseCase,
       super(const UsageAnalyticsState());

  /// Load usage analytics
  Future<void> loadAnalytics({int? periodDays}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final days = periodDays ?? state.periodDays;
      
      appLogger.info('Loading usage analytics', {
        'periodDays': days,
      });

      final result = await _getUsageAnalyticsUseCase.call(days);

      result.when(
        success: (analyticsData) {
          final analytics = UsageAnalytics.fromJson(analyticsData);
          state = state.copyWith(
            isLoading: false,
            analytics: analytics,
            periodDays: days,
          );

          appLogger.info('Usage analytics loaded successfully', {
            'periodDays': days,
            'totalConsumed': analytics.totalConsumed,
            'totalGranted': analytics.totalGranted,
            'netUsage': analytics.netUsage,
          });
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to load usage analytics: ${error.message}',
          );
          appLogger.error('Failed to load usage analytics', {
            'error': error.message,
            'periodDays': periodDays,
          });
        },
      );
    } catch (e) {
      appLogger.error('Failed to load usage analytics', {
        'error': e.toString(),
        'periodDays': periodDays,
      });
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load usage analytics: ${e.toString()}',
      );
    }
  }

  /// Refresh analytics
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }

  /// Get analytics for specific period
  Future<void> getAnalyticsForPeriod(int days) async {
    await loadAnalytics(periodDays: days);
  }

  /// Get consumption breakdown by type
  Map<String, int> getConsumptionBreakdown() {
    return state.analytics?.breakdownByType ?? {};
  }

  /// Get total consumption
  int get totalConsumption => state.analytics?.totalConsumed ?? 0;

  /// Get total granted
  int get totalGranted => state.analytics?.totalGranted ?? 0;

  /// Get net usage
  int get netUsage => state.analytics?.netUsage ?? 0;

  /// Get recent entries
  List<CreditConsumption> get recentEntries => state.analytics?.recentEntries ?? [];
}

/// Usage analytics provider
final usageAnalyticsProvider = StateNotifierProvider<UsageAnalyticsNotifier, UsageAnalyticsState>(
  (ref) => UsageAnalyticsNotifier(
    apiService: ref.watch(apiServiceProvider),
    getUsageAnalyticsUseCase: ref.watch(getUsageAnalyticsUseCaseProvider),
  ),
);

/// Usage analytics data provider
final usageAnalyticsDataProvider = Provider<UsageAnalytics?>((ref) {
  final state = ref.watch(usageAnalyticsProvider);
  return state.analytics;
});

/// Consumption breakdown provider
final consumptionBreakdownProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(usageAnalyticsProvider);
  return state.analytics?.breakdownByType ?? {};
});

/// Total consumption provider
final totalConsumptionProvider = Provider<int>((ref) {
  final state = ref.watch(usageAnalyticsProvider);
  return state.analytics?.totalConsumed ?? 0;
});

/// Total granted provider
final totalGrantedProvider = Provider<int>((ref) {
  final state = ref.watch(usageAnalyticsProvider);
  return state.analytics?.totalGranted ?? 0;
});

/// Net usage provider
final netUsageProvider = Provider<int>((ref) {
  final state = ref.watch(usageAnalyticsProvider);
  return state.analytics?.netUsage ?? 0;
});

/// Recent entries provider
final recentEntriesProvider = Provider<List<CreditConsumption>>((ref) {
  final state = ref.watch(usageAnalyticsProvider);
  return state.analytics?.recentEntries ?? [];
});
