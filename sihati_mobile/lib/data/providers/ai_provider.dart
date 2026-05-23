// lib/data/providers/ai_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';

/// AI provider — communicates with the Sihati backend AI endpoints
///
/// Available backend routes used:
///   POST /ai/interaction       → check drug interactions
///   POST /ai/chat              → general AI chat
///   POST /ai/ask-medication    → ask about a specific medication
///   GET  /ai/conversation/:id  → get conversation by ID
///   GET  /ai/history           → get conversation history
class AiProvider {
  final ApiService _apiService;

  AiProvider(this._apiService);

  // ─── Drug Interactions ───────────────────────────────────────────────

  /// Check drug interactions via AI
  /// Backend: POST /ai/interaction
  Future<Map<String, dynamic>> checkInteractions({
    required String med1,
    required String med2,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.AI_INTERACTION,
        data: {
          'med1': med1,
          'med2': med2,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data;
      }
      return {'safe': true, 'severity': 'low', 'reply': ''};
    } on DioException catch (e) {
      print('Interaction check error: ${e.message}');
      return {'safe': true, 'severity': 'low', 'reply': ''};
    }
  }

  // ─── AI Chat ──────────────────────────────────────────────────────────

  /// Send a message to the AI chat
  /// Backend: POST /ai/chat
  Future<Map<String, dynamic>> chat({
    required String message,
    List<Map<String, dynamic>>? history,
    Map<String, double>? location,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.AI_CHAT,
        data: {
          'message': message,
          if (history != null && history.isNotEmpty) 'history': history,
          if (location != null) 'location': location,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data;
      }
      return {'reply': 'Désolé, je ne peux pas répondre pour le moment.'};
    } on DioException catch (e) {
      print('AI chat error: ${e.message}');
      return {'reply': 'Désolé, je ne peux pas répondre pour le moment.'};
    }
  }

  // ─── Ask Medication ───────────────────────────────────────────────────

  /// Ask a question about a specific medication
  /// Backend: POST /ai/ask-medication
  Future<Map<String, dynamic>> askMedicationQuestion({
    required String medicationName,
    required String question,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.AI_ASK_MEDICATION,
        data: {
          'medicationName': medicationName,
          'question': question,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data;
      }
      return {'answer': 'Désolé, je ne peux pas répondre pour le moment.'};
    } on DioException catch (e) {
      print('Ask medication error: ${e.message}');
      return {'answer': 'Désolé, je ne peux pas répondre pour le moment.'};
    }
  }

  // ─── Conversation ─────────────────────────────────────────────────────

  /// Get a conversation by ID
  /// Backend: GET /ai/conversation/:id
  Future<Map<String, dynamic>?> getConversation(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.AI_CONVERSATION}/$id',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data;
      }
      return null;
    } on DioException catch (e) {
      print('Get conversation error: ${e.message}');
      return null;
    }
  }

  // ─── History ──────────────────────────────────────────────────────────

  /// Get conversation history
  /// Backend: GET /ai/history
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _apiService.get(ApiConstants.AI_HISTORY);
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['conversations'] ?? []);
      }
      return [];
    } on DioException catch (e) {
      print('Get history error: ${e.message}');
      return [];
    }
  }
}
