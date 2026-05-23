// lib/data/repositories/ai_repository.dart
import '../providers/ai_provider.dart';

class AiRepository {
  final AiProvider _aiProvider;

  AiRepository({required AiProvider aiProvider}) : _aiProvider = aiProvider;

  Future<String> checkDrugInteractions({
    required String med1,
    required String med2,
  }) async {
    try {
      final data = await _aiProvider.checkInteractions(
        med1: med1,
        med2: med2,
      );
      final safe = data['safe'] ?? true;
      final severity = data['severity'] ?? 'unknown';
      final reply = data['reply'] ?? '';

      if (safe) {
        return '✅ Aucune interaction connue entre $med1 et $med2.\n\n'
            'Consultez toujours votre médecin ou pharmacien avant de combiner des médicaments.';
      }

      final String emoji;
      switch (severity) {
        case 'high':
          emoji = '🚫';
          break;
        case 'moderate':
          emoji = '⚠️';
          break;
        default:
          emoji = '⚡';
      }

      return '$emoji Interaction détectée ($severity)\n\n'
          '$reply\n\n'
          '⚠️ Consultez votre médecin ou pharmacien.';
    } catch (e) {
      print('AiRepository.checkDrugInteractions error: $e');
      return "Impossible de vérifier l'interaction. Consultez un pharmacien.";
    }
  }

  Future<String> askMedicationQuestion({
    required String medicationName,
    required String question,
  }) async {
    try {
      final data = await _aiProvider.askMedicationQuestion(
        medicationName: medicationName,
        question: question,
      );
      return data['answer'] as String? ??
          'Désolé, je ne peux pas répondre à cette question.';
    } catch (e) {
      print('AiRepository.askMedicationQuestion error: $e');
      return 'Désolé, une erreur est survenue. Veuillez réessayer.';
    }
  }

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

  Future<Map<String, dynamic>?> getConversation(String id) async {
    try {
      return await _aiProvider.getConversation(id);
    } catch (e) {
      print('AiRepository.getConversation error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      return await _aiProvider.getHistory();
    } catch (e) {
      print('AiRepository.getHistory error: $e');
      return [];
    }
  }
}
