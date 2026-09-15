import '../../models/category.dart';
import '../../models/question.dart';
import '../../services/opentdb_service.dart';
import 'database_helper.dart';
 
/// Mapea nuestras 3 categorías (las del video) a los ids reales de
/// Open Trivia DB. Ver la lista completa en:
/// https://opentdb.com/api_category.php
class QuizRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final OpenTdbService _api = OpenTdbService();
 
  // IDs oficiales de OpenTDB: https://opentdb.com/api_category.php
  static final List<QuizCategory> localCategories = [
    QuizCategory(
      id: 9,
      name: 'General Knowledge',
      icon: 'assets/icons/general_knowledge.png',
      description: 'Test your general knowledge',
    ),
    QuizCategory(
      id: 11,
      name: 'Film',
      icon: 'assets/icons/film.png',
      description: 'Movies and cinema trivia',
    ),
    QuizCategory(
      id: 12,
      name: 'Music',
      icon: 'assets/icons/music.png',
      description: 'Songs, artists and albums',
    ),
    QuizCategory(
      id: 15,
      name: 'Video Games',
      icon: 'assets/icons/video_games.png',
      description: 'Video game trivia',
    ),
    QuizCategory(
      id: 20,
      name: 'Mythology',
      icon: 'assets/icons/mythology.png',
      description: 'Gods, myths and legends',
    ),
    QuizCategory(
      id: 22,
      name: 'Geography',
      icon: 'assets/icons/geography.png',
      description: 'Countries, capitals and maps',
    ),
    QuizCategory(
      id: 25,
      name: 'Art',
      icon: 'assets/icons/art.png',
      description: 'Paintings, painters and art history',
    ),
    QuizCategory(
      id: 27,
      name: 'Animals',
      icon: 'assets/icons/animals.png',
      description: 'The animal kingdom',
    ),
    QuizCategory(
      id: 32,
      name: 'Cartoon & Animations',
      icon: 'assets/icons/cartoons.png',
      description: 'Cartoons and animated films',
    ),
  ];
 
  /// Se llama una sola vez al arrancar la app (o cuando la tabla
  /// categories está vacía): inserta las 3 categorías fijas.
  Future<void> seedCategories() async {
    for (final category in localCategories) {
      await _db.insertCategory(category);
    }
  }
 
  /// Descarga preguntas de OpenTDB para [categoryId] y las guarda en
  /// SQLite, solo si esa categoría todavía no tiene preguntas locales
  /// (para no repetir el fetch cada vez que se abre el quiz).
  Future<List<QuizQuestion>> loadQuestions(int categoryId,
      {int amount = 10, bool forceRefresh = false}) async {
    final alreadyHasData = await _db.hasQuestionsForCategory(categoryId);
 
    if (!alreadyHasData || forceRefresh) {
      final rawResults = await _api.fetchQuestions(
        categoryId: categoryId,
        amount: amount,
      );
 
      for (final item in rawResults) {
        final question = QuizQuestion.fromOpenTdbJson(item, categoryId);
        await _db.insertQuestion(question);
      }
    }
 
    return _db.getQuestionsByCategory(categoryId);
  }
 
  Future<List<QuizCategory>> getCategories() => _db.getCategories();
}