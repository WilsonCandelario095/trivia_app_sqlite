import 'dart:convert';
import 'package:http/http.dart' as http;
 
/// Capa mínima que solo sabe hablar con la API de Open Trivia DB.
/// No conoce SQLite ni los modelos internos: devuelve el JSON crudo
/// (List<Map>) y que el repositorio decida cómo mapearlo.
class OpenTdbService {
  static const _baseUrl = 'https://opentdb.com/api.php';
 
  /// Trae [amount] preguntas de una categoría de OpenTDB.
  /// [categoryId] es el id numérico que usa OpenTDB (9 = General Knowledge,
  /// 17 = Science & Nature, 23 = History, etc).
  Future<List<Map<String, dynamic>>> fetchQuestions({
    required int categoryId,
    int amount = 10,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl?amount=$amount&category=$categoryId&type=multiple',
    );
 
    final response = await http.get(uri);
 
    if (response.statusCode != 200) {
      throw Exception('Error al conectar con Open Trivia DB '
          '(status ${response.statusCode})');
    }
 
    final body = jsonDecode(response.body) as Map<String, dynamic>;
 
    // response_code de OpenTDB: 0 = éxito, otros valores indican
    // problemas (sin resultados, param inválido, token agotado, etc).
    final responseCode = body['response_code'] as int;
    if (responseCode != 0) {
      throw Exception('Open Trivia DB devolvió response_code=$responseCode');
    }
 
    return List<Map<String, dynamic>>.from(body['results'] as List);
  }
}
