// lib/core/services/ai_service.dart
import 'package:get/get.dart';
import '../../app/constants/api_constants.dart';
import 'api_service.dart';

// ─── Models ───────────────────────────────────────────────────

enum UrgencyLevel { low, medium, high, emergency }

UrgencyLevel urgencyFromString(String? s) {
  switch (s) {
    case 'emergency':
      return UrgencyLevel.emergency;
    case 'high':
      return UrgencyLevel.high;
    case 'medium':
      return UrgencyLevel.medium;
    default:
      return UrgencyLevel.low;
  }
}

class ChatResponse {
  final String reply;
  final UrgencyLevel urgency;
  final bool isSymptomRelated;
  final String? suggestedSpecialty;
  final List<AIMedicationResult> medicationSuggestions;

  ChatResponse.fromJson(Map<String, dynamic> j)
      : reply = j['reply'] ?? '',
        urgency = urgencyFromString(j['urgency']),
        isSymptomRelated = j['isSymptomRelated'] ?? false,
        suggestedSpecialty = j['suggestedSpecialty'],
        medicationSuggestions = (j['medicationSuggestions'] as List? ?? [])
            .map((m) => AIMedicationResult.fromJson(m))
            .toList();
}

class AIMedicationResult {
  final String name;
  final String? genericName;
  final String? category;
  final bool requiresPrescription;
  final double? basePrice;
  final bool foundInDb;
  final List<PharmacyStock> availableInPharmacies;

  AIMedicationResult.fromJson(Map<String, dynamic> j)
      : name = j['name'] ?? '',
        genericName = j['genericName'],
        category = j['category'],
        requiresPrescription = j['requiresPrescription'] ?? false,
        basePrice = (j['basePrice'] as num?)?.toDouble(),
        foundInDb = j['foundInDb'] ?? false,
        availableInPharmacies = (j['availableInPharmacies'] as List? ?? [])
            .map((p) => PharmacyStock.fromJson(p))
            .toList();

  bool get hasStock => availableInPharmacies.any((p) => p.inStock);
  int get stockCount => availableInPharmacies.where((p) => p.inStock).length;
}

class PharmacyStock {
  final int pharmacyId;
  final String pharmacyName;
  final String wilaya;
  final String phone;
  final bool isOnDutyTonight;
  final bool inStock;
  final double? price;
  final double? distance;

  PharmacyStock.fromJson(Map<String, dynamic> j)
      : pharmacyId = j['pharmacyId'] ?? 0,
        pharmacyName = j['pharmacyName'] ?? '',
        wilaya = j['wilaya'] ?? '',
        phone = j['phone'] ?? '',
        isOnDutyTonight = j['isOnDutyTonight'] ?? false,
        inStock = j['inStock'] ?? false,
        price = (j['price'] as num?)?.toDouble(),
        distance = (j['distance'] as num?)?.toDouble();
}

class HistoryItem {
  final String role;
  final String text;

  HistoryItem({required this.role, required this.text});

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': [
          {'text': text}
        ],
      };
}

// ─── AI Service ───────────────────────────────────────────────

class AIService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<AIService> init() async {
    print('🤖 AI Service initialized — ${ApiConstants.BASE_URL}');
    return this;
  }

  // ─── POST /ai/chat ─────────────────────────────────────
  Future<ChatResponse> sendQuery(
    String message,
    List<HistoryItem> history, {
    double? lat,
    double? lng,
  }) async {
    try {
      final body = <String, dynamic>{
        'message': message,
        'history': history.map((h) => h.toJson()).toList(),
        if (lat != null && lng != null) 'location': {'lat': lat, 'lng': lng},
      };
      final response = await _apiService.post('/ai/chat', data: body);
      final data = response.data['data'] ?? response.data;
      return ChatResponse.fromJson(data);
    } catch (e) {
      print('❌ sendQuery error: $e');
      return ChatResponse.fromJson({
        'reply': _errorMessage(e),
        'urgency': 'low',
        'isSymptomRelated': false,
        'suggestedSpecialty': null,
        'medicationSuggestions': [],
      });
    }
  }

  // ─── POST /ai/interaction ──────────────────────────────
  Future<String> checkDrugInteraction({
    required String medication1,
    required String medication2,
  }) async {
    try {
      final response = await _apiService.post(
        '/ai/interaction',
        data: {'med1': medication1, 'med2': medication2},
      );
      final data = response.data['data'] ?? response.data;
      final safe = data['safe'] ?? true;
      final severity = data['severity'] ?? 'unknown';
      final reply = data['reply'] ?? '';

      if (safe) {
        return '✅ Aucune interaction connue entre $medication1 et $medication2.\n\n'
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
      print('❌ checkDrugInteraction error: $e');
      return "Impossible de vérifier l'interaction. Consultez un pharmacien.";
    }
  }

  // ─── POST /ai/ask-medication ────────────────────────────
  Future<String> askMedicationQuestion({
    required String medicationName,
    required String question,
  }) async {
    try {
      final response = await _apiService.post(
        '/ai/ask-medication',
        data: {
          'medicationName': medicationName,
          'question': question,
        },
      );
      final data = response.data['data'] ?? response.data;
      return data['answer'] as String? ??
          'Désolé, je ne peux pas répondre à cette question.';
    } catch (e) {
      print('❌ askMedicationQuestion error: $e');
      return 'Désolé, une erreur est survenue. Veuillez réessayer.';
    }
  }

  // ─── POST /ai/medication-info ──────────────────────────
  Future<Map<String, dynamic>> getMedicationInfo(String name) async {
    try {
      final response = await _apiService.post(
        '/ai/medication-info',
        data: {'medication': name},
      );
      final data = response.data['data'] ?? response.data;
      return {
        'reply': data['reply'] ?? '',
        'usage': data['usage'] ?? '',
        'dosage': data['dosage'] ?? '',
        'warnings': data['warnings'] ?? '',
        'foundInDb': data['foundInDb'] ?? false,
        'contraindications': data['contraindications'] ?? '',
        'sideEffects': data['sideEffects'] ?? '',
        'pregnancy': data['pregnancy'] ?? '',
        'interactions': data['interactions'] ?? '',
      };
    } catch (e) {
      print('❌ getMedicationInfo error: $e');
      return {
        'reply': 'Impossible de récupérer les informations.',
        'usage': '',
        'dosage': '',
        'warnings': '',
        'foundInDb': false,
        'contraindications': '',
        'sideEffects': '',
        'pregnancy': '',
        'interactions': '',
      };
    }
  }

  // ─── POST /ai/specialty ────────────────────────────────
  Future<Map<String, dynamic>> suggestSpecialty(String symptoms) async {
    try {
      final response = await _apiService.post(
        '/ai/specialty',
        data: {'symptoms': symptoms},
      );
      final data = response.data['data'] ?? response.data;
      return {
        'specialty': data['specialty'] ?? 'Médecine Générale',
        'reason': data['reason'] ?? '',
        'urgency': data['urgency'] ?? 'low',
      };
    } catch (e) {
      print('❌ suggestSpecialty error: $e');
      return {
        'specialty': 'Médecine Générale',
        'reason': 'Consultez un médecin généraliste.',
        'urgency': 'low',
      };
    }
  }

  // ─── GET /ai/conversation/:id ────────────────────────
  Future<Map<String, dynamic>?> getConversation(int id) async {
    try {
      final response = await _apiService.get('/ai/conversation/$id');
      final data = response.data['data'] ?? response.data;
      return data['conversation'] as Map<String, dynamic>;
    } catch (e) {
      print('❌ getConversation error: $e');
      return null;
    }
  }

  // ─── GET /ai/history ───────────────────────────────────
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _apiService.get('/ai/history');
      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data['conversations'] ?? []);
    } catch (e) {
      print('❌ getHistory error: $e');
      return [];
    }
  }

  String _errorMessage(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable')) {
      return '⚠️ Impossible de contacter le serveur.\nVérifiez votre connexion.';
    } else if (msg.contains('Connection refused')) {
      return '⚠️ Connexion refusée — vérifiez l\'URL: ${ApiConstants.BASE_URL}';
    } else if (msg.contains('Timeout')) {
      return '⏱️ Le serveur met trop de temps. Veuillez réessayer.';
    }
    return 'Erreur: $msg';
  }
}
