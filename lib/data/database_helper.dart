import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
 
import '../../models/category.dart';
import '../../models/question.dart';
import '../../models/quiz_attempt.dart';
 
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
 
  static Database? _database;
 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
 
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quiz_app.db');
 
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
 
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        description TEXT
      )
    ''');
 
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        incorrect_answers TEXT NOT NULL,
        difficulty TEXT,
        type TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
 
    await db.execute('''
      CREATE TABLE quiz_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
 
    await db.execute('''
      CREATE TABLE attempt_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attempt_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        user_answer TEXT,
        is_correct INTEGER NOT NULL,
        FOREIGN KEY (attempt_id) REFERENCES quiz_attempts (id),
        FOREIGN KEY (question_id) REFERENCES questions (id)
      )
    ''');
  }
 
  // ---------- Categories ----------
 
  Future<void> insertCategory(QuizCategory category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
 
  Future<List<QuizCategory>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((m) => QuizCategory.fromMap(m)).toList();
  }
 
  // ---------- Questions ----------
 
  Future<int> insertQuestion(QuizQuestion question) async {
    final db = await database;
    return db.insert('questions', question.toMap());
  }
 
  Future<List<QuizQuestion>> getQuestionsByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map((m) => QuizQuestion.fromMap(m)).toList();
  }
 
  Future<bool> hasQuestionsForCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'questions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
 
  // ---------- Quiz attempts (para la pantalla Summary) ----------
 
  Future<int> insertAttempt(QuizAttempt attempt) async {
    final db = await database;
    return db.insert('quiz_attempts', attempt.toMap());
  }
 
  Future<void> insertAttemptAnswer(AttemptAnswer answer) async {
    final db = await database;
    await db.insert('attempt_answers', answer.toMap());
  }
 
  Future<List<AttemptAnswer>> getAnswersForAttempt(int attemptId) async {
    final db = await database;
    final maps = await db.query(
      'attempt_answers',
      where: 'attempt_id = ?',
      whereArgs: [attemptId],
    );
    return maps.map((m) => AttemptAnswer.fromMap(m)).toList();
  }
 
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}