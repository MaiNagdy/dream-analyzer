import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../services/dream_service.dart';
import 'buy_credits_screen.dart';
import '../providers/auth_provider.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _dreamController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAnalyzing = false;
  String _statusMessage = '';
  bool _isServerHealthy = false;
  bool _hasCheckedServerHealth = false;

  @override
  void initState() {
    super.initState();
    // Don't check server health immediately to prevent crashes
    // Check it lazily when needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServerHealthQuietly();
    });
  }

  @override
  void dispose() {
    _dreamController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkServerHealthQuietly() async {
    try {
      final dreamService = Provider.of<DreamService>(context, listen: false);
      final isHealthy = await dreamService.checkServerHealth()
          .timeout(const Duration(seconds: 5));
      
      if (mounted) {
        setState(() {
          _isServerHealthy = isHealthy;
          _hasCheckedServerHealth = true;
        });
      }
    } catch (e) {
      // Silent check - don't show errors to user
      if (mounted) {
        setState(() {
          _isServerHealthy = false;
          _hasCheckedServerHealth = true;
        });
      }
    }
  }

  Future<void> _analyzeDream(String dreamText) async {
    // Check and consume a credit; if none, prompt user to buy
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final ok = authProv.consumeCredit();
    if (!ok) {
      _showMessage('رصيدك من التحليلات انتهى؛ يرجى شراء حزمة جديدة');
      _safeNavigate(const BuyCreditsScreen());
      return;
    }

    if (dreamText.trim().isEmpty) {
      _showMessage('يرجى إدخال حلمك أولاً');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusMessage = 'جاري تحليل حلمك بالذكاء الاصطناعي...';
    });

    try {
      final dreamService = Provider.of<DreamService>(context, listen: false);
      final analysis = await dreamService.analyzeDream(dreamText)
          .timeout(const Duration(seconds: 30)); // Longer timeout for analysis

      if (analysis != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(analysis: analysis),
          ),
        );
        _dreamController.clear();
        setState(() {
          _statusMessage = 'تم تحليل الحلم بنجاح ✅';
        });
      } else {
        if (mounted) {
          _showMessage('لم يتم تحليل الحلم. يرجى المحاولة مرة أخرى');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'خطأ في تحليل الحلم';
        if (e.toString().contains('timeout')) {
          errorMessage = 'انتهت مهلة الانتظار. يرجى المحاولة مرة أخرى';
        } else if (e.toString().contains('connection')) {
          errorMessage = 'مشكلة في الاتصال بالخادم';
        }
        _showMessage(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _statusMessage = '';
        });
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF6B46C1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('خطأ في تسجيل الخروج');
      }
    }
  }

  Future<void> _checkServerStatus() async {
    try {
      final dreamService = Provider.of<DreamService>(context, listen: false);
      final isHealthy = await dreamService.checkServerHealth()
          .timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          _isServerHealthy = isHealthy;
        });
        
        _showMessage(isHealthy 
            ? 'الخادم يعمل بشكل طبيعي ✅' 
            : 'الخادم غير متاح حالياً ❌');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isServerHealthy = false;
        });
        _showMessage('خطأ في فحص حالة الخادم');
      }
    }
  }

  void _safeNavigate(Widget screen) {
    if (mounted) {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => screen),
        );
      } catch (e) {
        _showMessage('خطأ في التنقل');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'محلل الأحلام',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _safeNavigate(const SettingsScreen()),
            ),
            // Add server status indicator
            if (_hasCheckedServerHealth)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  _isServerHealthy ? Icons.circle : Icons.circle_outlined,
                  color: _isServerHealthy ? Colors.green : Colors.orange,
                  size: 16,
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                try {
                  switch (value) {
                    case 'history':
                      _safeNavigate(const HistoryScreen());
                      break;
                    case 'tips':
                      _safeNavigate(const TipsScreen());
                      break;
                    case 'settings':
                      _safeNavigate(const SettingsScreen());
                      break;
                    case 'status':
                      _checkServerStatus();
                      break;
                    case 'logout':
                      _logout();
                      break;
                  }
                } catch (e) {
                  _showMessage('خطأ في العملية المطلوبة');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Color(0xFF6B46C1)),
                      SizedBox(width: 12),
                      Text('تاريخ الأحلام'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'tips',
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Color(0xFF6B46C1)),
                      SizedBox(width: 12),
                      Text('نصائح الأحلام'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Color(0xFF6B46C1)),
                      SizedBox(width: 12),
                      Text('الإعدادات الشخصية'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF6B46C1)),
                      SizedBox(width: 12),
                      Text('حالة الخادم'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message with user info
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.psychology,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        user?.fullName != null && user!.fullName!.isNotEmpty
                                            ? 'مرحباً ${user.fullName}'
                                            : 'مرحباً بك',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'أخبرنا عن حلمك وسنقوم بتحليله باستخدام الذكاء الاصطناعي',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                
                                // Server status indicator
                                if (_hasCheckedServerHealth) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        _isServerHealthy ? Icons.check_circle : Icons.warning_amber,
                                        color: _isServerHealthy ? Colors.green : Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isServerHealthy ? 'الخادم متصل' : 'الخادم غير متصل',
                                        style: TextStyle(
                                          color: _isServerHealthy ? Colors.green : Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Dream input section
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'أدخل حلمك',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _dreamController,
                                maxLines: 6,
                                textDirection: ui.TextDirection.rtl,
                                decoration: const InputDecoration(
                                  hintText: 'اكتب حلمك هنا بالتفصيل...',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isAnalyzing ? null : () {
                                    _analyzeDream(_dreamController.text);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isAnalyzing
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text('جاري التحليل...'),
                                          ],
                                        )
                                      : const Text(
                                          'تحليل الحلم',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              if (_statusMessage.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    color: Color(0xFF6B46C1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick actions
                      const Text(
                        'إجراءات سريعة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.history,
                              title: 'تاريخ الأحلام',
                              subtitle: 'عرض الأحلام السابقة',
                              onTap: () => _safeNavigate(const HistoryScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.tips_and_updates,
                              title: 'نصائح الأحلام',
                              subtitle: 'معلومات مفيدة',
                              onTap: () => _safeNavigate(const TipsScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: const Color(0xFF6B46C1),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}