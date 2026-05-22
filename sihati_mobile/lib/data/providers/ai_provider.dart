// lib/data/providers/ai_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';

/// AI provider — communicates with the Sihati backend AI endpoints
///
/// Available backend routes used:
///   POST /ai/interaction  → check drug interactions (body: { med1, med2 })
///   POST /ai/chat         → general AI chat (body: { message, history?, location? })
class AiProvider {
  final ApiService _apiService;

  AiProvider(this._apiService);

  // ─── Drug Interactions ───────────────────────────────────────────────

  /// Check drug interactions via AI
  /// Backend: POST /ai/interaction
  /// Body: { med1: string, med2: string }  ← medication names (not IDs)
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
      return {'hasInteractions': false, 'interactions': [], 'safeToTake': true};
    } on DioException catch (e) {
      print('Interaction check error: ${e.message}');
      return {'hasInteractions': false, 'interactions': [], 'safeToTake': true};
    }
  }

  // ─── AI Chat ──────────────────────────────────────────────────────────

  /// Send a message to the AI chat
  /// Backend: POST /ai/chat
  /// Body: { message, history?, location? }
  /// history: [{ role: 'user'|'model', parts: [{ text }] }]
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
}
