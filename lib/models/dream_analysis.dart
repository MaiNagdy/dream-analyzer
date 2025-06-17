class DreamAnalysis {
  final String? id;
  final String dreamText;
  final String analysis;
  final String advice;
  final DateTime timestamp;

  DreamAnalysis({
    this.id,
    required this.dreamText,
    required this.analysis,
    required this.advice,
    required this.timestamp,
  });

  factory DreamAnalysis.fromJson(Map<String, dynamic> json) {
    return DreamAnalysis(
      id: json['dream_id']?.toString(),
      dreamText: json['dream_text'] ?? '',
      analysis: json['analysis'] ?? '',
      advice: json['advice'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  factory DreamAnalysis.fromHistoryJson(Map<String, dynamic> json) {
    return DreamAnalysis(
      id: json['id']?.toString(),
      dreamText: json['dream_text'] ?? '',
      analysis: json['analysis'] ?? '',
      advice: json['advice'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dream_text': dreamText,
      'analysis': analysis,
      'advice': advice,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DreamAnalysis(id: $id, dreamText: $dreamText, analysis: $analysis, advice: $advice, timestamp: $timestamp)';
  }
} 