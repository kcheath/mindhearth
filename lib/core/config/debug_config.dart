import 'package:flutter/foundation.dart';

/// Debug configuration for development and testing
class DebugConfig {
  static const bool _kDebugMode = kDebugMode;
  
  /// Whether debug mode is enabled
  static bool get isDebugMode => _kDebugMode;
  
  /// Whether billing debug features are enabled
  static bool get isBillingDebugEnabled => _kDebugMode;
  
  /// Whether development endpoints are available
  static bool get areDevEndpointsAvailable => _kDebugMode;
  
  /// Whether fake payment providers are enabled
  static bool get isFakeProviderEnabled => _kDebugMode;
  
  /// Whether IAP validation is stubbed
  static bool get isIAPValidationStubbed => _kDebugMode;
  
  /// Whether ledger is in fake mode
  static bool get isLedgerFakeMode => _kDebugMode;
  
  /// Debug settings for billing
  static const Map<String, dynamic> billingDebugSettings = {
    'ledger_mode': 'fake',
    'iap_validation_mode': 'stub',
    'fake_provider_mode': 'auto',
    'fake_provider_success_rate': 1.0,
    'fake_provider_delay_ms': 100,
    'fake_provider_error_rate': 0.0,
    'questions_per_credit': 10,
  };
  
  /// Development endpoints configuration
  static const Map<String, String> devEndpoints = {
    'seed_credits': '/api/billing/dev/seed',
    'top_up_credits': '/api/billing/dev/top-up',
    'simulate_purchase': '/api/billing/dev/purchase',
    'reset_billing': '/api/billing/dev/reset',
    'billing_health': '/api/billing/health',
    'billing_mode': '/api/billing/mode',
    'billing_status': '/api/billing/status',
    'billing_balance': '/api/billing/balance',
    'billing_ledger': '/api/billing/ledger',
    'check_operation': '/api/billing/check-operation',
  };
  
  /// Get debug settings for a specific feature
  static T getDebugSetting<T>(String key, T defaultValue) {
    if (!isDebugMode) return defaultValue;
    
    final settings = billingDebugSettings;
    return settings[key] as T? ?? defaultValue;
  }
  
  /// Check if a debug feature is enabled
  static bool isDebugFeatureEnabled(String feature) {
    if (!isDebugMode) return false;
    
    switch (feature) {
      case 'billing_debug':
        return isBillingDebugEnabled;
      case 'dev_endpoints':
        return areDevEndpointsAvailable;
      case 'fake_provider':
        return isFakeProviderEnabled;
      case 'iap_stub':
        return isIAPValidationStubbed;
      case 'fake_ledger':
        return isLedgerFakeMode;
      default:
        return false;
    }
  }
  
  /// Get development endpoint URL
  static String getDevEndpoint(String endpointName) {
    if (!areDevEndpointsAvailable) {
      throw StateError('Development endpoints not available in production');
    }
    
    final endpoint = devEndpoints[endpointName];
    if (endpoint == null) {
      throw ArgumentError('Unknown development endpoint: $endpointName');
    }
    
    return endpoint;
  }
  
  /// Debug logging configuration
  static const Map<String, bool> debugLogging = {
    'api_calls': true,
    'billing_operations': true,
    'payment_validation': true,
    'credit_calculations': true,
    'error_details': true,
  };
  
  /// Check if debug logging is enabled for a category
  static bool isDebugLoggingEnabled(String category) {
    if (!isDebugMode) return false;
    return debugLogging[category] ?? false;
  }
  
  /// API URL for development
  static String get apiUrl => 'http://localhost:8000/api';
  
  /// Test email for development
  static String get testEmail => 'test@tsukiyo.dev';
  
  /// Show debug banner
  static bool get showDebugBanner => _kDebugMode;
  
  /// Enable performance overlay
  static bool get enablePerformanceOverlay => false;
}