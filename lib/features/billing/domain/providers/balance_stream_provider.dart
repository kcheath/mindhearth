import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Balance stream state
@freezed
class BalanceStreamState with _$BalanceStreamState {
  const factory BalanceStreamState({
    @Default(0) int balance,
    @Default(false) bool isConnected,
    String? error,
    @Default(false) bool isLoading,
  }) = _BalanceStreamState;

  factory BalanceStreamState.fromJson(Map<String, dynamic> json) =>
      _$BalanceStreamStateFromJson(json);
}

/// Balance stream notifier
class BalanceStreamNotifier extends StateNotifier<BalanceStreamState> {
  final ApiService _apiService;
  StreamSubscription? _streamSubscription;
  Timer? _heartbeatTimer;

  BalanceStreamNotifier(this._apiService) : super(const BalanceStreamState());

  /// Start balance streaming
  Future<void> startStreaming() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      appLogger.info('Starting balance stream');

      // Start heartbeat timer to keep connection alive
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _sendHeartbeat();
      });

      // Start streaming
      _streamSubscription = _apiService.dio.get(
        '/api/billing/balance-stream',
        options: Options(
          responseType: ResponseType.stream,
        ),
      ).asStream().listen(
        (response) {
          if (response.statusCode == 200) {
            _handleStreamResponse(response);
          }
        },
        onError: (error) {
          appLogger.error('Balance stream error', {
            'error': error.toString(),
          });
          state = state.copyWith(
            isConnected: false,
            error: 'Stream error: ${error.toString()}',
          );
        },
      );

      state = state.copyWith(
        isLoading: false,
        isConnected: true,
      );

      appLogger.info('Balance stream started successfully');
    } catch (e) {
      appLogger.error('Failed to start balance stream', {
        'error': e.toString(),
      });
      state = state.copyWith(
        isLoading: false,
        isConnected: false,
        error: 'Failed to start stream: ${e.toString()}',
      );
    }
  }

  /// Stop balance streaming
  void stopStreaming() {
    appLogger.info('Stopping balance stream');
    
    _streamSubscription?.cancel();
    _streamSubscription = null;
    
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    state = state.copyWith(
      isConnected: false,
    );
  }

  /// Handle stream response
  void _handleStreamResponse(Response response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('balance')) {
        final balance = data['balance'] as int;
        
        state = state.copyWith(
          balance: balance,
          isConnected: true,
          error: null,
        );

        appLogger.info('Balance updated from stream', {
          'balance': balance,
        });
      }
    } catch (e) {
      appLogger.error('Failed to handle stream response', {
        'error': e.toString(),
      });
    }
  }

  /// Send heartbeat to keep connection alive
  void _sendHeartbeat() {
    try {
      _apiService.dio.post('/api/billing/heartbeat');
    } catch (e) {
      appLogger.error('Heartbeat failed', {
        'error': e.toString(),
      });
    }
  }

  /// Get current balance
  Future<int> getCurrentBalance() async {
    try {
      final response = await _apiService.dio.get('/api/billing/balance');
      if (response.statusCode == 200) {
        final balance = response.data['balance'] as int;
        
        state = state.copyWith(balance: balance);
        
        appLogger.info('Current balance retrieved', {
          'balance': balance,
        });
        
        return balance;
      }
      return 0;
    } catch (e) {
      appLogger.error('Failed to get current balance', {
        'error': e.toString(),
      });
      return 0;
    }
  }

  @override
  void dispose() {
    stopStreaming();
    super.dispose();
  }
}

/// Balance stream provider
final balanceStreamProvider = StateNotifierProvider<BalanceStreamNotifier, BalanceStreamState>(
  (ref) => BalanceStreamNotifier(ref.watch(apiServiceProvider)),
);

/// Live balance provider
final liveBalanceProvider = Provider<AsyncValue<int>>((ref) {
  final streamState = ref.watch(balanceStreamProvider);
  
  if (streamState.isLoading) {
    return const AsyncValue.loading();
  }
  
  if (streamState.error != null) {
    return AsyncValue.error(streamState.error!, StackTrace.current);
  }
  
  return AsyncValue.data(streamState.balance);
});

/// Balance stream connection status provider
final balanceStreamConnectionProvider = Provider<bool>((ref) {
  final streamState = ref.watch(balanceStreamProvider);
  return streamState.isConnected;
});

/// Balance stream error provider
final balanceStreamErrorProvider = Provider<String?>((ref) {
  final streamState = ref.watch(balanceStreamProvider);
  return streamState.error;
});
