import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Subscription product IDs
  static const String pack10Dreams = 'pack_10_dreams';
  static const String pack30Dreams = 'pack_30_dreams';
  
  static const List<String> _productIds = [pack10Dreams, pack30Dreams];
  
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;

  Future<void> initialize() async {
    debugPrint('🔄 Initializing SubscriptionService...');
    
    // Check if IAP is available
    _isAvailable = await _inAppPurchase.isAvailable();
    debugPrint('📱 IAP Available: $_isAvailable');
    
    if (!_isAvailable) {
      debugPrint('❌ In-app purchases not available');
      return;
    }

    // Enable pending purchases (required for subscriptions)
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      await androidAddition.enablePendingPurchases();
      debugPrint('✅ Enabled pending purchases for Android');
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => debugPrint('🔚 Purchase stream done'),
      onError: (error) => debugPrint('❌ Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();
    
    debugPrint('✅ SubscriptionService initialized successfully');
  }

  Future<void> loadProducts() async {
    debugPrint('🔄 Loading subscription products...');
    
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds.toSet());
      
      if (response.error != null) {
        _queryProductError = response.error!.message;
        debugPrint('❌ Product query error: ${response.error}');
        return;
      }

      if (response.productDetails.isEmpty) {
        _queryProductError = 'No products found. Make sure products are configured in Google Play Console.';
        debugPrint('⚠️ No subscription products found');
        return;
      }

      _products = response.productDetails;
      _queryProductError = null;
      
      debugPrint('✅ Loaded ${_products.length} subscription products:');
      for (var product in _products) {
        debugPrint('  📦 ${product.id}: ${product.title} - ${product.price}');
      }
      
    } catch (e) {
      _queryProductError = 'Failed to load products: $e';
      debugPrint('❌ Exception loading products: $e');
    }
  }

  Future<bool> buySubscription(String productId) async {
    if (!_isAvailable) {
      debugPrint('❌ Cannot buy: IAP not available');
      return false;
    }

    final ProductDetails? productDetails = _products
        .where((product) => product.id == productId)
        .firstOrNull;

    if (productDetails == null) {
      debugPrint('❌ Product $productId not found');
      return false;
    }

    _purchasePending = true;
    debugPrint('🛒 Starting purchase for ${productDetails.id}...');

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('🛒 Purchase initiated: $success');
      return success;
      
    } catch (e) {
      _purchasePending = false;
      debugPrint('❌ Purchase error: $e');
      return false;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('📦 Purchase update received: ${purchaseDetailsList.length} items');
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('🔍 Processing purchase: ${purchaseDetails.productID} - ${purchaseDetails.status}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          // Verify purchase with backend
          await _verifyAndDeliverProduct(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
          debugPrint('✅ Completed purchase: ${purchaseDetails.productID}');
        }
      }
    }
    
    _purchasePending = false;
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    debugPrint('🔐 Verifying purchase with backend...');
    
    try {
      // Get auth token from secure storage
      final prefs = await import('../services/auth_service.dart');
      final authToken = await AuthService().getAuthToken();
      
      if (authToken == null) {
        debugPrint('❌ No auth token available');
        return;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/subscriptions/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'productId': purchaseDetails.productID,
          'purchaseToken': purchaseDetails.verificationData.serverVerificationData,
        }),
      );

      debugPrint('🌐 Verification response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Subscription verified: ${data['message']}');
        debugPrint('💳 Credits added: ${data['credits_added']}');
        
        // Show success message
        // Note: You might want to use a callback or state management here
        
      } else {
        debugPrint('❌ Verification failed: ${response.body}');
      }
      
    } catch (e) {
      debugPrint('❌ Verification error: $e');
    }
  }

  void _showPendingUI() {
    debugPrint('⏳ Purchase pending...');
    // Show pending UI to user
  }

  void _handleError(IAPError error) {
    debugPrint('❌ Purchase error: ${error.message}');
    _purchasePending = false;
    // Show error to user
  }

  Future<void> restorePurchases() async {
    debugPrint('🔄 Restoring purchases...');
    
    if (!_isAvailable) {
      debugPrint('❌ Cannot restore: IAP not available');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ Restore purchases completed');
    } catch (e) {
      debugPrint('❌ Restore purchases error: $e');
    }
  }

  Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    try {
      // Get auth token
      final prefs = await import('../services/auth_service.dart');
      final authToken = await AuthService().getAuthToken();
      
      if (authToken == null) {
        debugPrint('❌ No auth token for subscription status');
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/subscriptions/status'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('❌ Failed to get subscription status: ${response.statusCode}');
        return null;
      }
      
    } catch (e) {
      debugPrint('❌ Get subscription status error: $e');
      return null;
    }
  }

  Future<bool> cancelSubscription() async {
    try {
      // Get auth token
      final prefs = await import('../services/auth_service.dart');
      final authToken = await AuthService().getAuthToken();
      
      if (authToken == null) {
        debugPrint('❌ No auth token for cancellation');
        return false;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/subscriptions/cancel'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Subscription cancelled');
        return true;
      } else {
        debugPrint('❌ Failed to cancel subscription: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ Cancel subscription error: $e');
      return false;
    }
  }

  void dispose() {
    _subscription.cancel();
    debugPrint('🔚 SubscriptionService disposed');
  }
} 