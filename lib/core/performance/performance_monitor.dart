import 'dart:async';
import 'dart:io';
import 'package:mindhearth/core/services/logger.dart';

/// Performance monitoring and optimization for MindHearth
/// 
/// This class provides comprehensive performance monitoring including:
/// - API response time tracking
/// - Memory usage monitoring
/// - Battery usage tracking
/// - Performance metrics collection
class PerformanceMonitor {
  static final _logger = AppLogger('PerformanceMonitor');
  
  // Performance metrics storage
  static final Map<String, List<PerformanceMetric>> _metrics = {};
  static final Map<String, Stopwatch> _activeTimers = {};
  
  // Configuration
  static const Duration _maxMetricAge = Duration(hours: 24);
  static const int _maxMetricsPerOperation = 1000;

  /// Start timing an operation
  static String startTimer(String operationName) {
    final timerId = '${operationName}_${DateTime.now().millisecondsSinceEpoch}';
    _activeTimers[timerId] = Stopwatch()..start();
    
    _logger.debug('Started timer for: $operationName (ID: $timerId)');
    return timerId;
  }

  /// Stop timing an operation and record the metric
  static void stopTimer(String timerId, String operationName, {
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = _activeTimers.remove(timerId);
    if (stopwatch == null) {
      _logger.warning('Timer not found for ID: $timerId');
      return;
    }

    stopwatch.stop();
    final duration = Duration(milliseconds: stopwatch.elapsedMilliseconds);
    
    _recordMetric(PerformanceMetric(
      operationName: operationName,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    ));

    _logger.debug('Stopped timer for: $operationName (Duration: ${duration.inMilliseconds}ms)');
  }

  /// Record a performance metric
  static void _recordMetric(PerformanceMetric metric) {
    final operationName = metric.operationName;
    
    if (!_metrics.containsKey(operationName)) {
      _metrics[operationName] = [];
    }
    
    _metrics[operationName]!.add(metric);
    
    // Clean up old metrics
    _cleanupOldMetrics(operationName);
    
    // Limit metrics per operation
    if (_metrics[operationName]!.length > _maxMetricsPerOperation) {
      _metrics[operationName]!.removeAt(0);
    }
  }

  /// Clean up old metrics
  static void _cleanupOldMetrics(String operationName) {
    final now = DateTime.now();
    _metrics[operationName]!.removeWhere(
      (metric) => now.difference(metric.timestamp) > _maxMetricAge,
    );
  }

  /// Get performance statistics for an operation
  static PerformanceStats getStats(String operationName) {
    final metrics = _metrics[operationName] ?? [];
    
    if (metrics.isEmpty) {
      return PerformanceStats(
        operationName: operationName,
        totalCalls: 0,
        averageDuration: Duration.zero,
        minDuration: Duration.zero,
        maxDuration: Duration.zero,
        successRate: 0.0,
      );
    }

    final durations = metrics.map((m) => m.duration).toList();
    final totalDuration = durations.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    
    final averageDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ durations.length,
    );
    
    final minDuration = durations.reduce((a, b) => a < b ? a : b);
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);
    
    final successfulCalls = metrics.where((m) => m.metadata['success'] == true).length;
    final successRate = successfulCalls / metrics.length;

    return PerformanceStats(
      operationName: operationName,
      totalCalls: metrics.length,
      averageDuration: averageDuration,
      minDuration: minDuration,
      maxDuration: maxDuration,
      successRate: successRate,
    );
  }

  /// Get all performance statistics
  static Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    
    for (final operationName in _metrics.keys) {
      stats[operationName] = getStats(operationName);
    }
    
    return stats;
  }

  /// Monitor memory usage
  static Future<MemoryUsage> getMemoryUsage() async {
    try {
      // This is a simplified implementation
      // In a real app, you might use platform-specific APIs
      final processInfo = ProcessInfo.currentRss;
      
      return MemoryUsage(
        usedMemory: processInfo,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.warning('Failed to get memory usage: $e');
      return MemoryUsage(
        usedMemory: 0,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Monitor battery usage (simplified)
  static BatteryUsage getBatteryUsage() {
    // This is a simplified implementation
    // In a real app, you would use platform-specific battery APIs
    return BatteryUsage(
      level: 100, // Placeholder
      isCharging: false, // Placeholder
      timestamp: DateTime.now(),
    );
  }

  /// Get performance recommendations
  static List<PerformanceRecommendation> getRecommendations() {
    final recommendations = <PerformanceRecommendation>[];
    final stats = getAllStats();
    
    for (final stat in stats.values) {
      // Check for slow operations
      if (stat.averageDuration.inMilliseconds > 5000) {
        recommendations.add(PerformanceRecommendation(
          type: RecommendationType.slowOperation,
          operationName: stat.operationName,
          message: 'Operation ${stat.operationName} is slow (avg: ${stat.averageDuration.inMilliseconds}ms)',
          severity: RecommendationSeverity.warning,
        ));
      }
      
      // Check for high failure rate
      if (stat.successRate < 0.8) {
        recommendations.add(PerformanceRecommendation(
          type: RecommendationType.highFailureRate,
          operationName: stat.operationName,
          message: 'Operation ${stat.operationName} has high failure rate (${(stat.successRate * 100).toStringAsFixed(1)}%)',
          severity: RecommendationSeverity.error,
        ));
      }
      
      // Check for frequent calls
      if (stat.totalCalls > 100) {
        recommendations.add(PerformanceRecommendation(
          type: RecommendationType.frequentCalls,
          operationName: stat.operationName,
          message: 'Operation ${stat.operationName} is called frequently (${stat.totalCalls} times)',
          severity: RecommendationSeverity.info,
        ));
      }
    }
    
    return recommendations;
  }

  /// Clear all metrics
  static void clearMetrics() {
    _metrics.clear();
    _activeTimers.clear();
    _logger.info('Performance metrics cleared');
  }

  /// Export metrics for analysis
  static Map<String, dynamic> exportMetrics() {
    final export = <String, dynamic>{};
    
    for (final entry in _metrics.entries) {
      export[entry.key] = entry.value.map((m) => m.toJson()).toList();
    }
    
    return export;
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'operationName': operationName,
    'durationMs': duration.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

/// Performance statistics
class PerformanceStats {
  final String operationName;
  final int totalCalls;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final double successRate;

  const PerformanceStats({
    required this.operationName,
    required this.totalCalls,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.successRate,
  });

  @override
  String toString() {
    return 'PerformanceStats('
        'operationName: $operationName, '
        'totalCalls: $totalCalls, '
        'averageDuration: ${averageDuration.inMilliseconds}ms, '
        'minDuration: ${minDuration.inMilliseconds}ms, '
        'maxDuration: ${maxDuration.inMilliseconds}ms, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// Memory usage information
class MemoryUsage {
  final int usedMemory;
  final DateTime timestamp;

  const MemoryUsage({
    required this.usedMemory,
    required this.timestamp,
  });
}

/// Battery usage information
class BatteryUsage {
  final int level;
  final bool isCharging;
  final DateTime timestamp;

  const BatteryUsage({
    required this.level,
    required this.isCharging,
    required this.timestamp,
  });
}

/// Performance recommendation
class PerformanceRecommendation {
  final RecommendationType type;
  final String operationName;
  final String message;
  final RecommendationSeverity severity;

  const PerformanceRecommendation({
    required this.type,
    required this.operationName,
    required this.message,
    required this.severity,
  });
}

/// Recommendation types
enum RecommendationType {
  slowOperation,
  highFailureRate,
  frequentCalls,
  memoryUsage,
  batteryUsage,
}

/// Recommendation severity levels
enum RecommendationSeverity {
  info,
  warning,
  error,
}
