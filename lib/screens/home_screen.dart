import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../services/dream_service.dart';
import '../providers/auth_provider.dart';
import '../models/dream_analysis.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';

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

  @override
  void dispose() {
    _dreamController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _analyzeDream(String dreamText) async {
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
      final analysis = await dreamService.analyzeDream(dreamText);

      if (analysis != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(analysis: analysis),
          ),
        );
        _dreamController.clear();
      } else {
        _showMessage('فشل تحليل الحلم. يرجى التحقق من تشغيل الخادم.');
      }
    } catch (e) {
      _showMessage('خطأ: ${e.toString()}');
    } finally {
      setState(() {
        _isAnalyzing = false;
        _statusMessage = '';
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B46C1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
      _showMessage('خطأ في تسجيل الخروج');
    }
  }

  Future<void> _checkServerStatus() async {
    final dreamService = Provider.of<DreamService>(context, listen: false);
    final isHealthy = await dreamService.checkServerHealth();
    
    _showMessage(isHealthy 
        ? 'الخادم يعمل بشكل طبيعي ✅' 
        : 'الخادم غير متاح حالياً ❌');
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
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'history':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                    break;
                  case 'tips':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TipsScreen(),
                      ),
                    );
                    break;
                  case 'status':
                    _checkServerStatus();
                    break;
                  case 'logout':
                    _logout();
                    break;
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
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.nights_stay,
                        size: 48,
                        color: Color(0xFF6B46C1),
                      ),
                      const SizedBox(height: 12),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.user;
                          return Text(
                            user != null
                                ? 'مرحباً بك ${user.fullName ?? user.username}'
                                : 'مرحباً بك في محلل الأحلام',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اكتشف المعاني الخفية في أحلامك باستخدام الذكاء الاصطناعي',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Dream Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'أخبرني عن حلمك',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      
                      // Text Input
                      TextField(
                        controller: _dreamController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'اوصف حلمك بالتفصيل...\n\nمثال: "كنت أطير فوق منظر طبيعي جميل، ولكن بعد ذلك بدأت أسقط..."',
                          hintMaxLines: 4,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Analyze Button
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing 
                            ? null 
                            : () => _analyzeDream(_dreamController.text),
                        icon: _isAnalyzing 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.psychology),
                        label: Text(_isAnalyzing ? 'جاري التحليل...' : 'تحليل الحلم'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Status Message
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFFF1F5F9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6B46C1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Quick Actions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإجراءات السريعة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAction(
                              Icons.history,
                              'عرض التاريخ',
                              'شاهد أحلامك السابقة',
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const HistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickAction(
                              Icons.tips_and_updates,
                              'نصائح الأحلام',
                              'حسن نتائجك',
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TipsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Features Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المميزات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.psychology, 'التحليل بالذكاء الاصطناعي', 
                          'احصل على تفسيرات مفصلة باستخدام ChatGPT'),
                      _buildFeature(Icons.insights, 'رؤى عميقة', 
                          'فهم المعنى النفسي لأحلامك'),
                      _buildFeature(Icons.lightbulb, 'نصائح شخصية', 
                          'تلقى رؤى وتوصيات مخصصة'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6B46C1),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6B46C1),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}