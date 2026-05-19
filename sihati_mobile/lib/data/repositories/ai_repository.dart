// lib/data/repositories/ai_repository.dart
import '../providers/ai_provider.dart';

/// AI repository — wraps AiProvider with error handling.
///
/// Currently wired:
///   - checkInteractions(med1, med2) → POST /ai/interaction
///   - chat(message, history?, location?) → POST /ai/chat
///
/// Not yet wired (backend routes exist, not exposed in app):
///   - POST /ai/ask-medication
///   - POST /ai/medication-info
///   - POST /ai/specialty
///   - GET  /ai/history
class AiRepository {
  final AiProvider _aiProvider;

  AiRepository({required AiProvider aiProvider})
      : _aiProvider = aiProvider;

  /// Check drug interactions between two medications
  /// Backend: POST /ai/interaction
  /// [med1] and [med2] are medication NAMES (not IDs)
  Future<Map<String, dynamic>> checkDrugInteractions({
    required String med1,
    required String med2,
  }) async {
    try {
      return await _aiProvider.checkInteractions(
        med1: med1,
        med2: med2,
      );
    } catch (e) {
      print('AiRepository.checkDrugInteractions error: $e');
      return {
        'hasInteractions': false,
        'interactions': [],
        'safeToTake': true,
      };
    }
  }

  /// Send a message to the AI chat assistant
  /// Backend: POST /ai/chat
  /// [history] format: [{ role: 'user'|'model', parts: [{ text }] }]
  Future<Map<String, dynamic>> chat({
    required String message,
    List<Map<String, dynamic>>? history,
    Map<String, double>? location,
  }) async {
    try {
      return await _aiProvider.chat(
        message: message,
        history: history,
        location: location,
      );
    } catch (e) {
      print('AiRepository.chat error: $e');
      return {
        'reply': 'Désolé, une erreur est survenue. Veuillez réessayer.',
      };
    }
  }
}
