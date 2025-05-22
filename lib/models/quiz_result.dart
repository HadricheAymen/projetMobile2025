class QuizResult {
  final String nickname;
  final int score;
  final int totalQuestions;
  final String category;
  final String difficulty;
  final DateTime timestamp;

  QuizResult({
    required this.nickname,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'score': score,
        'totalQuestions': totalQuestions,
        'category': category,
        'difficulty': difficulty,
        'timestamp': timestamp.toIso8601String(),
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        nickname: json['nickname'],
        score: json['score'],
        totalQuestions: json['totalQuestions'],
        category: json['category'],
        difficulty: json['difficulty'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}