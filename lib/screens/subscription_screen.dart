import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptions();
  }

  Future<void> _initializeSubscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _subscriptionService.initialize();
      await _refreshSubscriptionStatus();
    } catch (e) {
      setState(() {
        _error = 'فشل في تحميل الاشتراكات: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshSubscriptionStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshSubscriptionStatus();
  }

  Future<void> _buySubscription(String productId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await _subscriptionService.buySubscription(productId);
      if (!success) {
        setState(() {
          _error = 'فشل في بدء عملية الشراء';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في الشراء: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelSubscription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الاشتراك'),
        content: const Text('هل أنت متأكد من إلغاء الاشتراك؟ لن يتم تجديده تلقائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = AuthService();
        final success = await authService.cancelSubscription();
        
        if (success) {
          await _refreshSubscriptionStatus();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إلغاء التجديد التلقائي')),
            );
          }
        } else {
          setState(() {
            _error = 'فشل في إلغاء الاشتراك';
          });
        }
      } catch (e) {
        setState(() {
          _error = 'خطأ في إلغاء الاشتراك: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشتراكات'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return RefreshIndicator(
                    onRefresh: _refreshSubscriptionStatus,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrentStatus(authProvider),
                          const SizedBox(height: 24),
                          _buildSubscriptionPlans(),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            _buildErrorCard(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCurrentStatus(AuthProvider authProvider) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  authProvider.hasActiveSubscription ? Icons.verified : Icons.stars,
                  color: authProvider.hasActiveSubscription ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'حالة الاشتراك الحالية',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (authProvider.hasActiveSubscription) ...[
              _buildStatusRow('النوع', _getSubscriptionTypeName(authProvider.subscriptionType)),
              _buildStatusRow(
                'ينتهي في', 
                authProvider.subscriptionEndDate?.toLocal().toString().split(' ')[0] ?? 'غير محدد'
              ),
              _buildStatusRow(
                'التجديد التلقائي', 
                authProvider.subscriptionAutoRenew ? 'مفعل' : 'معطل'
              ),
              const SizedBox(height: 12),
              if (authProvider.subscriptionAutoRenew)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cancelSubscription,
                    icon: const Icon(Icons.cancel),
                    label: const Text('إلغاء التجديد التلقائي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.2),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
            ] else ...[
              Text(
                'ليس لديك اشتراك نشط',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusRow('رصيد الأحلام', '${authProvider.credits}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خطط الاشتراك',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_subscriptionService.products.isEmpty)
          _buildNoProductsCard()
        else
          ..._subscriptionService.products.map(_buildSubscriptionCard).toList(),
      ],
    );
  }

  Widget _buildNoProductsCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد خطط اشتراك متاحة حالياً',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _initializeSubscriptions,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(ProductDetails product) {
    final isRecommended = product.id == 'pack_30_dreams';
    final dreams = product.id == 'pack_10_dreams' ? 10 : 30;
    final period = product.id == 'pack_10_dreams' ? 'شهرياً' : 'شهرياً';

    return Card(
      color: isRecommended 
          ? Colors.amber.withOpacity(0.2)
          : Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product.title.split(' (')[0], // Remove app name
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'الأفضل',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dreams حلم $period',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _subscriptionService.purchasePending
                    ? null
                    : () => _buySubscription(product.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecommended 
                      ? Colors.amber 
                      : Colors.blue,
                  foregroundColor: isRecommended 
                      ? Colors.black 
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _subscriptionService.purchasePending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'اشترك الآن',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _error = null),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubscriptionTypeName(String? type) {
    switch (type) {
      case 'pack_10_dreams':
        return 'باقة 10 أحلام';
      case 'pack_30_dreams':
        return 'باقة 30 حلم';
      default:
        return 'غير محدد';
    }
  }
} 