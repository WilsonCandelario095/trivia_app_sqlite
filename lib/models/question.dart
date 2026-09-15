import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
 
final _htmlUnescape = HtmlUnescape();
 
class QuizQuestion {
  final int? id; // null hasta que se inserta (autoincrement)
  final int categoryId;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String difficulty;
  final String type; // "multiple" o "boolean"
 
  QuizQuestion({
    this.id,
    required this.categoryId,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.difficulty,
    required this.type,
  });
 
  /// Devuelve las 4 opciones (o 2, si es boolean) ya mezcladas.
  /// Usamos una semilla derivada del id de la pregunta para que el orden
  /// sea estable si se vuelve a construir el widget (evita que las
  /// opciones "salten" al hacer setState).
  List<String> shuffledOptions() {
    final options = [...incorrectAnswers, correctAnswer];
    options.shuffle();
    return options;
  }
 
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'question': question,
      'correct_answer': correctAnswer,
      'incorrect_answers': jsonEncode(incorrectAnswers),
      'difficulty': difficulty,
      'type': type,
    };
  }
 
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      question: map['question'] as String,
      correctAnswer: map['correct_answer'] as String,
      incorrectAnswers:
          List<String>.from(jsonDecode(map['incorrect_answers'] as String)),
      difficulty: map['difficulty'] as String,
      type: map['type'] as String,
    );
  }
 
  /// Construye directamente desde un item del JSON de Open Trivia DB,
  /// decodificando las entidades HTML que OpenTDB manda por defecto
  /// (&quot;, &#039;, &amp;, etc).
  factory QuizQuestion.fromOpenTdbJson(
      Map<String, dynamic> json, int categoryId) {
    return QuizQuestion(
      categoryId: categoryId,
      question: _decodeHtml(json['question'] as String),
      correctAnswer: _decodeHtml(json['correct_answer'] as String),
      incorrectAnswers: (json['incorrect_answers'] as List)
          .map((e) => _decodeHtml(e as String))
          .toList(),
      difficulty: json['difficulty'] as String,
      type: json['type'] as String,
    );
  }
 
  static String _decodeHtml(String input) {
    // Cubre &quot; &#039; &amp; &Uuml; &ccedil; &ldquo; &rdquo; &eacute;
    // y cualquier otra entidad nombrada o numérica (&#123; / &#x7B;).
    return _htmlUnescape.convert(input).trim();
  }
}