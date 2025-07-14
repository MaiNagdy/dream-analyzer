import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../models/dream_analysis.dart';

class AnalysisScreen extends StatefulWidget {
  final DreamAnalysis analysis;
  
  const AnalysisScreen({super.key, required this.analysis});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تحليل الحلم',
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
              icon: const Icon(Icons.share),
              onPressed: _shareAnalysis,
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Card
              Card(
                color: const Color(0xFFF8FAFC),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF6B46C1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMMM yyyy - HH:mm', 'ar').format(widget.analysis.timestamp),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Dream Text Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.nights_stay,
                            color: Color(0xFF6B46C1),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'حلمك',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          widget.analysis.dreamText,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Analysis Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.psychology,
                            color: Color(0xFF6B46C1),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'التحليل بالذكاء الاصطناعي',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0F9FF), Color(0xFFEFF6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          widget.analysis.analysis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Advice Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Color(0xFFF59E0B),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'النصائح الشخصية',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          widget.analysis.advice,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.home),
                      label: const Text('حلم جديد'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF6B46C1)),
                        foregroundColor: const Color(0xFF6B46C1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareAnalysis,
                      icon: const Icon(Icons.share),
                      label: const Text('مشاركة'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAnalysis() {
    final shareText = '''
تحليل الحلم - ${DateFormat('dd MMMM yyyy', 'ar').format(widget.analysis.timestamp)}

الحلم: ${widget.analysis.dreamText}

التحليل: ${widget.analysis.analysis}

النصيحة: ${widget.analysis.advice}

مُولد بواسطة محلل الأحلام بالذكاء الاصطناعي
''';
    
    Share.share(
      shareText,
      subject: 'تحليل حلمي',
    );
  }
}