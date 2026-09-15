class QuizAttempt {
  final int? id;
  final int categoryId;
  final int score;
  final int totalQuestions;
  final String date; // ISO8601
 
  QuizAttempt({
    this.id,
    required this.categoryId,
    required this.score,
    required this.totalQuestions,
    required this.date,
  });
 
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'score': score,
      'total_questions': totalQuestions,
      'date': date,
    };
  }
 
  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      date: map['date'] as String,
    );
  }
}
 
class AttemptAnswer {
  final int? id;
  final int attemptId;
  final int questionId;
  final String? userAnswer; // null si no respondió
  final bool isCorrect;
 
  AttemptAnswer({
    this.id,
    required this.attemptId,
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
  });
 
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'is_correct': isCorrect ? 1 : 0,
    };
  }
 
  factory AttemptAnswer.fromMap(Map<String, dynamic> map) {
    return AttemptAnswer(
      id: map['id'] as int?,
      attemptId: map['attempt_id'] as int,
      questionId: map['question_id'] as int,
      userAnswer: map['user_answer'] as String?,
      isCorrect: (map['is_correct'] as int) == 1,
    );
  }
}