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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
      );

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final msg = result['message'] ?? 'حدث خطأ، يرجى المحاولة مرة أخرى';
        _showErrorDialog(msg);
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء إنشاء الحساب');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: const Text('خطأ'),
          content: Text(message),
          actions: [
            // Show "Login instead" button if email is already registered
            if (message.contains('Email already registered') || message.contains('البريد الإلكتروني مسجل مسبقاً'))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to login screen
                },
                child: const Text('تسجيل الدخول بدلاً من ذلك'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
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
                  
                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      if (value.length < 3) {
                        return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Full name field (optional)
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Phone field (optional)
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Gender dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'الجنس',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('ذكر')),
                      DropdownMenuItem(value: 'female', child: Text('أنثى')),
                    ],
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date of birth field
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الميلاد',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'اختر تاريخ الميلاد',
                        style: TextStyle(
                          color: _selectedDate != null ? null : Colors.grey[600],
                        ),
                      ),
                    ),
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
                  
                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        disabledBackgroundColor: const Color(0xFF6B46C1).withOpacity(0.6),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'إنشاء الحساب',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('لديك حساب بالفعل؟ '),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
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