import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _personalityController = TextEditingController();
  final _concernsController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedAgeRange;
  String? _selectedRelationshipStatus;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _jobController.dispose();
    _hobbiesController.dispose();
    _personalityController.dispose();
    _concernsController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        _selectedGender = user.gender;
        _selectedAgeRange = user.ageRange;
        _selectedRelationshipStatus = user.relationshipStatus;
        _jobController.text = user.job ?? '';
        _hobbiesController.text = user.hobbies ?? '';
        _personalityController.text = user.personality ?? '';
        _concernsController.text = user.currentConcerns ?? '';
      });
    }
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create updated user settings data
      final settingsData = {
        'gender': _selectedGender,
        'age_range': _selectedAgeRange,
        'relationship_status': _selectedRelationshipStatus,
        'job': _jobController.text.trim().isEmpty ? null : _jobController.text.trim(),
        'hobbies': _hobbiesController.text.trim().isEmpty ? null : _hobbiesController.text.trim(),
        'personality': _personalityController.text.trim().isEmpty ? null : _personalityController.text.trim(),
        'current_concerns': _concernsController.text.trim().isEmpty ? null : _concernsController.text.trim(),
      };
      
      // Here you would call your backend API to save user profile settings
      // For now, we'll simulate a save operation and store locally
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the user in auth provider (in a real app, this would come from API response)
      await authProvider.updateUserSettings(settingsData);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات بنجاح', textDirection: ui.TextDirection.rtl),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _hasChanges = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء حفظ الإعدادات', textDirection: ui.TextDirection.rtl),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            'الإعدادات الشخصية',
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
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveSettings,
                child: const Text(
                  'حفظ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_pin,
                          size: 48,
                          color: Color(0xFF6B46C1),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'معلومات إضافية لتحسين التحليل',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هذه المعلومات ستساعد الذكاء الاصطناعي على تقديم تحليل أدق وأكثر تخصصاً لأحلامك',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Basic Information Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF6B46C1),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'المعلومات الأساسية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
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
                            DropdownMenuItem(value: 'prefer_not_to_say', child: Text('أفضل عدم الإجابة')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedGender = value);
                            _markChanged();
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Age range dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedAgeRange,
                          decoration: const InputDecoration(
                            labelText: 'الفئة العمرية',
                            prefixIcon: Icon(Icons.cake),
                          ),
                          items: const [
                            DropdownMenuItem(value: '13-17', child: Text('13-17 سنة')),
                            DropdownMenuItem(value: '18-25', child: Text('18-25 سنة')),
                            DropdownMenuItem(value: '26-35', child: Text('26-35 سنة')),
                            DropdownMenuItem(value: '36-45', child: Text('36-45 سنة')),
                            DropdownMenuItem(value: '46-55', child: Text('46-55 سنة')),
                            DropdownMenuItem(value: '56+', child: Text('56+ سنة')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedAgeRange = value);
                            _markChanged();
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Relationship status
                        DropdownButtonFormField<String>(
                          value: _selectedRelationshipStatus,
                          decoration: const InputDecoration(
                            labelText: 'الحالة الاجتماعية',
                            prefixIcon: Icon(Icons.favorite),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'single', child: Text('أعزب/عزباء')),
                            DropdownMenuItem(value: 'married', child: Text('متزوج/متزوجة')),
                            DropdownMenuItem(value: 'divorced', child: Text('مطلق/مطلقة')),
                            DropdownMenuItem(value: 'widowed', child: Text('أرمل/أرملة')),
                            DropdownMenuItem(value: 'prefer_not_to_say', child: Text('أفضل عدم الإجابة')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRelationshipStatus = value);
                            _markChanged();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Professional & Personal Information Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: Color(0xFF10B981),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'المعلومات المهنية والشخصية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Job field
                        TextFormField(
                          controller: _jobController,
                          decoration: const InputDecoration(
                            labelText: 'المهنة أو الوظيفة',
                            prefixIcon: Icon(Icons.work),
                            hintText: 'مثال: طبيب، مهندس، طالب، ربة منزل',
                          ),
                          onChanged: (_) => _markChanged(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Hobbies field
                        TextFormField(
                          controller: _hobbiesController,
                          decoration: const InputDecoration(
                            labelText: 'الهوايات والاهتمامات',
                            prefixIcon: Icon(Icons.interests),
                            hintText: 'مثال: القراءة، الرياضة، الرسم، الموسيقى',
                          ),
                          maxLines: 2,
                          onChanged: (_) => _markChanged(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Personality traits
                        TextFormField(
                          controller: _personalityController,
                          decoration: const InputDecoration(
                            labelText: 'سمات الشخصية',
                            prefixIcon: Icon(Icons.psychology),
                            hintText: 'مثال: هادئ، طموح، قلق، اجتماعي',
                          ),
                          maxLines: 2,
                          onChanged: (_) => _markChanged(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current Life Situation Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.mood,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'الوضع الحالي في الحياة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Current concerns or focuses
                        TextFormField(
                          controller: _concernsController,
                          decoration: const InputDecoration(
                            labelText: 'التحديات أو الاهتمامات الحالية',
                            prefixIcon: Icon(Icons.help_outline),
                            hintText: 'مثال: ضغط العمل، تغيير في الحياة، قرارات مهمة',
                          ),
                          maxLines: 3,
                          onChanged: (_) => _markChanged(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasChanges ? const Color(0xFF6B46C1) : Colors.grey,
                      foregroundColor: Colors.white,
                      elevation: _hasChanges ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _hasChanges && !_isLoading ? _saveSettings : null,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _hasChanges ? 'حفظ التغييرات' : 'لا توجد تغييرات',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color(0xFF1E40AF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'هذه المعلومات آمنة ومشفرة وتستخدم فقط لتحسين دقة تحليل أحلامك',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 