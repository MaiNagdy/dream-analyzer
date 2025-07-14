import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 1. Clear previous error and validate form
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 2. Call the login method
      final result = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // If login fails, the widget will still be mounted.
      // If login succeeds, the AuthWrapper will navigate away.
      if (mounted && !result['success']) {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'حدث خطأ غير متوقع';
        });
      }

    } catch (e) {
      // Handle exceptions like network errors
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل الاتصال بالخادم. حاول مرة أخرى';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo and title
                      Icon(
                        Icons.psychology,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'محلل الأحلام',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'اكتشف معاني أحلامك بالذكاء الاصطناعي',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Login form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني أو اسم المستخدم',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال البريد الإلكتروني أو اسم المستخدم';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 32),

                            // Error message container - only shows when there's an error
                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red, 
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textDirection: ui.TextDirection.rtl,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Fixed login button with better styling
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B46C1),
                                  disabledBackgroundColor: const Color(0xFF6B46C1).withOpacity(0.6),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: const Color(0xFF6B46C1).withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('ليس لديك حساب؟ '),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => const RegisterScreen(),
                                            ),
                                          );
                                        },
                                  child: const Text(
                                    'إنشاء حساب جديد',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ], // end Column children
                        ), // end Column
                      ), // end Form
                    ], // end outer Column children
                  ), // end Column
                ),
              );
            },
          ),
        ), // end SafeArea
      ), // end Scaffold
    ); // end Directionality
  }
} 