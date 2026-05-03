import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

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
      : pharmacyId = j['pharmacyId'],
        pharmacyName = j['pharmacyName'],
        wilaya = j['wilaya'],
        phone = j['phone'],
        isOnDutyTonight = j['isOnDutyTonight'] ?? false,
        inStock = j['inStock'] ?? false,
        price = (j['price'] as num?)?.toDouble(),
        distance = (j['distance'] as num?)?.toDouble();
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
      : name = j['name'],
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

class ChatResponse {
  final String reply;
  final UrgencyLevel urgency;
  final bool isSymptomRelated;
  final String? suggestedSpecialty;
  final List<AIMedicationResult> medicationSuggestions;

  ChatResponse.fromJson(Map<String, dynamic> j)
      : reply = j['reply'],
        urgency = urgencyFromString(j['urgency']),
        isSymptomRelated = j['isSymptomRelated'] ?? false,
        suggestedSpecialty = j['suggestedSpecialty'],
        medicationSuggestions = (j['medicationSuggestions'] as List? ?? [])
            .map((m) => AIMedicationResult.fromJson(m))
            .toList();
}

class InteractionResponse {
  final bool safe;
  final String severity;
  final String reply;

  InteractionResponse.fromJson(Map<String, dynamic> j)
      : safe = j['safe'] ?? true,
        severity = j['severity'] ?? 'unknown',
        reply = j['reply'] ?? '';
}

class MedicationInfoResponse {
  // Original fields — unchanged
  final String reply;
  final String usage;
  final String dosage;
  final String warnings;
  final bool foundInDb;
  final Map<String, dynamic>? dbData;

  // Extended fields for detail screen — default to '' if backend doesn't send them
  final String contraindications;
  final String sideEffects;
  final String pregnancy;
  final String interactions;

  MedicationInfoResponse.fromJson(Map<String, dynamic> j)
      : reply = j['reply'] ?? '',
        usage = j['usage'] ?? '',
        dosage = j['dosage'] ?? '',
        warnings = j['warnings'] ?? '',
        foundInDb = j['foundInDb'] ?? false,
        dbData = j['dbData'],
        contraindications = j['contraindications'] ?? '',
        sideEffects = j['sideEffects'] ?? '',
        pregnancy = j['pregnancy'] ?? '',
        interactions = j['interactions'] ?? '';
}

class SpecialtyResponse {
  final String specialty;
  final String reason;
  final UrgencyLevel urgency;

  SpecialtyResponse.fromJson(Map<String, dynamic> j)
      : specialty = j['specialty'] ?? 'Médecine Générale',
        reason = j['reason'] ?? '',
        urgency = urgencyFromString(j['urgency']);
}

// Conversation history item — mirrors backend ChatHistoryItem
class HistoryItem {
  final String role; // 'user' | 'model'
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
  // ⚠️ Change based on your environment
  static const String BASE_URL = 'http://192.168.1.105:3000';
  // Android emulator: 'http://10.0.2.2:3000'
  // iOS simulator:    'http://localhost:3000'
  // Production:       'https://your-backend.onrender.com'

  String? _authToken;

  Future<AIService> init() async {
    print('🤖 AI Service initialized — $BASE_URL');
    final ok = await _testConnection();
    print(ok ? '✅ Backend reachable' : '⚠️ Backend not reachable at $BASE_URL');
    return this;
  }

  void setAuthToken(String? token) {
    _authToken = token;
    print('🔑 Auth token ${token != null ? "set" : "cleared"}');
  }

  // ─── Shared helpers ────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Uri.parse('$BASE_URL$path'),
          headers: _headers,
          body: json.encode(body),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout'),
        );

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data['data'] as Map<String, dynamic>;
    }

    if (response.statusCode == 429) {
      throw Exception("Limite d'utilisation atteinte. Veuillez patienter.");
    }

    throw Exception(data['message'] ?? 'Erreur serveur');
  }

  // ─── POST /api/ai/chat ─────────────────────────────────────
  // Sends message + history + optional GPS location
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
      final data = await _post('/api/ai/chat', body);
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

  // ─── POST /api/ai/interaction ──────────────────────────────
  Future<String> checkDrugInteraction({
    required String medication1,
    required String medication2,
  }) async {
    try {
      final data = await _post(
        '/api/ai/interaction',
        {'med1': medication1, 'med2': medication2},
      );
      final response = InteractionResponse.fromJson(data);

      if (response.safe) {
        return '✅ Aucune interaction connue entre $medication1 et $medication2.\n\n'
            'Consultez toujours votre médecin ou pharmacien avant de combiner des médicaments.';
      }

      final String emoji;
      switch (response.severity) {
        case 'high':
          emoji = '🚫';
          break;
        case 'moderate':
          emoji = '⚠️';
          break;
        default:
          emoji = '⚡';
      }

      return '$emoji Interaction détectée (${response.severity})\n\n'
          '${response.reply}\n\n'
          '⚠️ Consultez votre médecin ou pharmacien.';
    } catch (e) {
      print('❌ checkDrugInteraction error: $e');
      return "Impossible de vérifier l'interaction. Consultez un pharmacien.";
    }
  }

  // ─── POST /api/ai/ask-medication ────────────────────────────
  Future<String> askMedicationQuestion({
    required String medicationName,
    required String question,
  }) async {
    try {
      final data = await _post('/api/ai/ask-medication', {
        'medicationName': medicationName,
        'question': question,
      });
      return data['answer'] as String? ??
          'Désolé, je ne peux pas répondre à cette question.';
    } catch (e) {
      print('❌ askMedicationQuestion error: $e');
      return 'Désolé, une erreur est survenue. Veuillez réessayer.';
    }
  }

  // ─── POST /api/ai/medication-info ──────────────────────────
  Future<MedicationInfoResponse> getMedicationInfo(String name) async {
    try {
      final data = await _post('/api/ai/medication-info', {'medication': name});
      return MedicationInfoResponse.fromJson(data);
    } catch (e) {
      print('❌ getMedicationInfo error: $e');
      return MedicationInfoResponse.fromJson({
        'reply': 'Impossible de récupérer les informations.',
        'usage': '',
        'dosage': '',
        'warnings': '',
        'foundInDb': false,
      });
    }
  }

  // ─── POST /api/ai/specialty ────────────────────────────────
  Future<SpecialtyResponse> suggestSpecialty(String symptoms) async {
    try {
      final data = await _post('/api/ai/specialty', {'symptoms': symptoms});
      return SpecialtyResponse.fromJson(data);
    } catch (e) {
      print('❌ suggestSpecialty error: $e');
      return SpecialtyResponse.fromJson({
        'specialty': 'Médecine Générale',
        'reason': 'Consultez un médecin généraliste.',
        'urgency': 'low',
      });
    }
  }

  // ─── GET /api/ai/conversation/:id ────────────────────────
  Future<Map<String, dynamic>?> getConversation(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/api/ai/conversation/$id'),
              headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['conversation'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ getConversation error: $e');
      return null;
    }
  }

  // ─── GET /api/ai/history ───────────────────────────────────
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/api/ai/history'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(
            data['data']['conversations'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ getHistory error: $e');
      return [];
    }
  }

  // ─── Connection test ───────────────────────────────────────

  Future<bool> _testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String _errorMessage(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable')) {
      return '⚠️ Impossible de contacter le serveur.\nVérifiez que le backend tourne sur:\n$BASE_URL';
    } else if (msg.contains('Connection refused')) {
      return '⚠️ Connexion refusée — vérifiez l\'URL: $BASE_URL';
    } else if (msg.contains('Timeout')) {
      return '⏱️ Le serveur met trop de temps. Veuillez réessayer.';
    }
    return 'Erreur: $msg';
  }
}
