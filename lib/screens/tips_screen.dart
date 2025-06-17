import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'نصائح الأحلام',
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
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                        Icons.lightbulb,
                        size: 48,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'نصائح تحليل الأحلام',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'احصل على نتائج تحليل أفضل مع هذه النصائح المفيدة',
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
              
              const SizedBox(height: 16),
              
              // Dream Recall Tips
              _buildTipSection(
                'تذكر أحلامك',
                Icons.memory,
                const Color(0xFF3B82F6),
                [
                  'احتفظ بمفكرة أحلام بجانب سريرك',
                  'اكتب الأحلام فور الاستيقاظ',
                  'ضع نية لتذكر الأحلام قبل النوم',
                  'استيقظ بشكل طبيعي عند الإمكان (بدون منبه)',
                  'ابق في السرير لبضع دقائق بعد الاستيقاظ',
                  'ركز على المشاعر والأحاسيس أولاً',
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Writing Tips
              _buildTipSection(
                'كتابة أوصاف أحلام أفضل',
                Icons.edit,
                const Color(0xFF10B981),
                [
                  'اشمل التفاصيل المحددة والألوان',
                  'اوصف المشاعر التي شعرت بها خلال الحلم',
                  'لاحظ أي أشخاص أو أماكن أو أشياء',
                  'اذكر تسلسل الأحداث',
                  'اشمل أي حوار أو أصوات',
                  'لا تقلق بشأن القواعد - ركز على المحتوى',
                ],
              ),
              
              const SizedBox(height: 16),
              
              // AI Analysis Tips
              _buildTipSection(
                'الحصول على تحليل ذكاء اصطناعي أفضل',
                Icons.psychology,
                const Color(0xFF8B5CF6),
                [
                  'قدم سياقاً عن وضع حياتك الحالي',
                  'اذكر الموضوعات أو الرموز المتكررة',
                  'اشمل كيف شعرت عند الاستيقاظ',
                  'لاحظ أي صلات بالأحداث الأخيرة',
                  'كن صادقاً حول التفاصيل الشخصية',
                  'اطرح أسئلة محددة إذا كان لديك',
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Example Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.article,
                            color: Color(0xFFEF4444),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'مثال على وصف الحلم',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Text(
                          'كنت أطير فوق منظر طبيعي جميل بحقول ذهبية وسماء زرقاء مشرقة. شعرت بحرية وفرح لا يصدقان. فجأة، بدأت أسقط نحو غابة مظلمة أدناه، وأصبحت قلقاً جداً. قبل أن أصطدم بالأشجار مباشرة، استيقظت وقلبي يخفق بسرعة.\n\nكنت أشعر بالتوتر حول قرار كبير في العمل مؤخراً، وحدث هذا الحلم في الليلة التي سبقت اجتماعاً مهماً.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '✅ هذا الوصف يشمل المشاعر والتفاصيل المحددة وتسلسل الأحداث والأحاسيس الجسدية والسياق الشخصي.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipSection(String title, IconData icon, Color color, List<String> tips) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
} 