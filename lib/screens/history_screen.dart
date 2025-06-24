import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../models/dream_analysis.dart';
import '../services/dream_service.dart';
import 'analysis_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DreamAnalysis> _dreams = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDreamHistory();
  }

  Future<void> _loadDreamHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dreamService = Provider.of<DreamService>(context, listen: false);
      final dreams = await dreamService.getDreamHistory();
      setState(() {
        _dreams = dreams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dream history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تاريخ الأحلام',
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
              icon: const Icon(Icons.refresh),
              onPressed: _loadDreamHistory,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6B46C1)),
            SizedBox(height: 16),
            Text(
              'جاري تحميل أحلامك...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDreamHistory,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_dreams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.nights_stay,
              size: 64,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 16),
            const Text(
              'لم يتم تحليل أي أحلام بعد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بتحليل حلمك الأول!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('تحليل الحلم'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dreams.length,
      itemBuilder: (context, index) {
        final dream = _dreams[index];
        return _buildDreamCard(dream);
      },
    );
  }

  Widget _buildDreamCard(DreamAnalysis dream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnalysisScreen(analysis: dream),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.nights_stay,
                        color: Color(0xFF6B46C1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(dream.timestamp),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Dream preview
              Text(
                dream.dreamText.length > 150 
                    ? '${dream.dreamText.substring(0, 150)}...'
                    : dream.dreamText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Analysis preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: Color(0xFF1E40AF),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dream.analysis.length > 100 
                            ? '${dream.analysis.substring(0, 100)}...'
                            : dream.analysis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tap to view full analysis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('HH:mm').format(dream.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'اضغط لعرض التحليل الكامل',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B46C1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color(0xFF6B46C1),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 