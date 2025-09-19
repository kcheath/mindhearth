import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// In-app purchase service for mobile platforms
/// Handles purchase validation and product management
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs for credit packages
  static const Map<String, String> _productIds = {
    'starter_pack': 'com.mindhearth.credits.starter',
    'healer_pack': 'com.mindhearth.credits.healer',
    'warrior_pack': 'com.mindhearth.credits.warrior',
    'champion_pack': 'com.mindhearth.credits.champion',
  };

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];

  /// Initialize the IAP service
  Future<bool> initialize() async {
    try {
      // Check if IAP is available
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        appLogger.warning('In-app purchases not available on this device');
        return false;
      }

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => appLogger.info('Purchase stream closed'),
        onError: (error) => appLogger.error('Purchase stream error', {'error': error.toString()}),
      );

      // Load products
      await _loadProducts();
      
      appLogger.info('IAP service initialized successfully');
      return true;
    } catch (e) {
      appLogger.error('Failed to initialize IAP service', {'error': e.toString()});
      return false;
    }
  }

  /// Load available products
  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = _productIds.values.toSet();
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        appLogger.warning('Products not found', {'notFound': response.notFoundIDs});
      }
      
      _products = response.productDetails;
      appLogger.info('Products loaded', {'count': _products.length});
    } catch (e) {
      appLogger.error('Failed to load products', {'error': e.toString()});
    }
  }

  /// Get available products
  List<ProductDetails> get products => _products;

  /// Check if IAP is available
  bool get isAvailable => _isAvailable;

  /// Get product by package ID
  ProductDetails? getProduct(String packageId) {
    final productId = _productIds[packageId];
    if (productId == null) return null;
    
    return _products.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw StateError('Product not found'),
    );
  }

  /// Purchase a product
  Future<bool> purchaseProduct(String packageId) async {
    try {
      final product = getProduct(packageId);
      if (product == null) {
        appLogger.error('Product not found', {'packageId': packageId});
        return false;
      }

      appLogger.info('Starting purchase', {
        'packageId': packageId,
        'productId': product.id,
        'price': product.price,
      });

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        appLogger.info('Purchase initiated successfully', {'packageId': packageId});
      } else {
        appLogger.warning('Purchase initiation failed', {'packageId': packageId});
      }
      
      return success;
    } catch (e) {
      appLogger.error('Purchase failed', {
        'packageId': packageId,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      appLogger.info('Purchase update', {
        'productId': purchaseDetails.productID,
        'status': purchaseDetails.status.toString(),
        'error': purchaseDetails.error?.message,
      });

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleRestoredPurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle pending purchase
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    appLogger.info('Purchase pending', {'productId': purchaseDetails.productID});
    _purchases.add(purchaseDetails);
  }

  /// Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    appLogger.info('Purchase successful', {
      'productId': purchaseDetails.productID,
      'purchaseId': purchaseDetails.purchaseID,
    });
    
    _purchases.add(purchaseDetails);
    
    // In a real implementation, you would validate the purchase with your backend
    // and update the user's credit balance
  }

  /// Handle failed purchase
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    appLogger.error('Purchase failed', {
      'productId': purchaseDetails.productID,
      'error': purchaseDetails.error?.message,
    });
  }

  /// Handle restored purchase
  void _handleRestoredPurchase(PurchaseDetails purchaseDetails) {
    appLogger.info('Purchase restored', {
      'productId': purchaseDetails.productID,
      'purchaseId': purchaseDetails.purchaseID,
    });
    
    _purchases.add(purchaseDetails);
  }

  /// Handle canceled purchase
  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    appLogger.info('Purchase canceled', {'productId': purchaseDetails.productID});
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      appLogger.info('Restoring purchases');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      appLogger.error('Failed to restore purchases', {'error': e.toString()});
    }
  }

  /// Get purchase history
  List<PurchaseDetails> get purchases => _purchases;

  /// Dispose the service
  void dispose() {
    _subscription.cancel();
    appLogger.info('IAP service disposed');
  }
}
