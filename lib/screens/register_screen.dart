import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final String emailTrimmed = _emailController.text.trim();
      String derivedUsername = emailTrimmed.split('@').first;
      // Remove non-alphanumeric characters and ensure length >=3
      derivedUsername = derivedUsername.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      if (derivedUsername.length < 3) {
        derivedUsername = (derivedUsername + DateTime.now().millisecondsSinceEpoch.toString()).substring(0, 6);
      }

      final result = await authProvider.register(
        email: emailTrimmed,
        username: derivedUsername,
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      // Always reset loading state first
      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (!mounted) return;

      if (result['success']) {
        // Small delay to ensure state is properly updated
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Check for specific registration errors
        final msg = result['message'] ?? 'حدث خطأ، يرجى المحاولة مرة أخرى';
        String specificMessage = msg;
        
        // Handle email already registered error
        if (msg.contains('البريد الإلكتروني مسجل مسبقاً') || 
            msg.contains('email already') || 
            msg.contains('already registered')) {
          specificMessage = 'هذا البريد الإلكتروني مسجل مسبقاً. يرجى تسجيل الدخول أو استخدام بريد إلكتروني آخر';
        }
        // Handle generic validation errors
        else if (msg.contains('بيانات غير صحيحة') || 
                 msg.contains('invalid') || 
                 msg.contains('validation')) {
          specificMessage = 'يرجى التحقق من صحة البيانات المدخلة';
        }
        // Handle network errors
        else if (msg.contains('network') || msg.contains('connection')) {
          specificMessage = 'مشكلة في الاتصال. يرجى المحاولة مرة أخرى';
        }
        
        _showErrorDialog(specificMessage);
      }
    } catch (e) {
      // Always reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
      
      if (!mounted) return;
      _showErrorDialog('حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى');
      print('Registration error: $e'); // Debug info
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    // Check if this is an "email already registered" error
    bool isEmailAlreadyRegistered = message.contains('البريد الإلكتروني مسجل مسبقاً') ||
                                   message.contains('email already') ||
                                   message.contains('already registered') ||
                                   message.contains('مسجل مسبقاً');
    
    // Show SnackBar first for immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: ui.TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        backgroundColor: isEmailAlreadyRegistered ? Colors.orange : Colors.red,
        action: isEmailAlreadyRegistered ? SnackBarAction(
          label: 'تسجيل دخول',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pop(); // Go back to login
          },
        ) : null,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                isEmailAlreadyRegistered ? Icons.email_outlined : Icons.error,
                color: isEmailAlreadyRegistered ? Colors.orange : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isEmailAlreadyRegistered ? 'البريد الإلكتروني مسجل مسبقاً' : 'خطأ في إنشاء الحساب'
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (isEmailAlreadyRegistered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'يبدو أن هذا البريد الإلكتروني مسجل مسبقاً. يمكنك تسجيل الدخول بدلاً من إنشاء حساب جديد',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'تأكد من صحة البيانات المدخلة وحاول مرة أخرى',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (isEmailAlreadyRegistered)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to login screen
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حاول مرة أخرى'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء حساب جديد'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Full name field (required)
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل *',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      if (value.length < 2) {
                        return 'الاسم يجب أن يكون حرفين على الأقل';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني *',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور *',
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
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      if (value.length > 50) {
                        return 'كلمة المرور طويلة جداً';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Fixed register button with better styling
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
                      onPressed: _isLoading ? null : _register,
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
                              'إنشاء الحساب',
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
                      const Text('لديك حساب بالفعل؟ '),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 