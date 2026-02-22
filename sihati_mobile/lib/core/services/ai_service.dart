import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';

/// AI Service using Google Gemini API (FREE)
/// Provides medical information, symptom checking, and medication advice
class AIService extends GetxService {
  late final GenerativeModel _model;

  // FREE Gemini API key - Get yours at: https://makersuite.google.com/app/apikey
  // For production, store this in environment variables or secure storage
  static const String _apiKey =
      'AIzaSyA1Eqqa2jpkkDD_INaca4KvKmHQXJpvydU'; // Replace with your key

  Future<AIService> init() async {
    // Initialize Gemini model (Gemini 1.5 Flash - fastest, free)
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1000,
      ),
      safetySettings: [
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.low,
        ),
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.low,
        ),
      ],
      systemInstruction: Content.system('''
Tu es un assistant médical intelligent pour l'application Sihati en Algérie.

RÈGLES IMPORTANTES:
1. Réponds TOUJOURS en français (ou en arabe si demandé)
2. Tu n'es PAS un médecin - ne pose jamais de diagnostic définitif
3. Conseille de consulter un médecin pour les cas sérieux
4. Reste précis et concis (3-5 phrases max)
5. Suggère des médicaments en vente libre pour les symptômes mineurs
6. Pour les symptômes graves: recommande une consultation immédiate

CONTEXTE ALGÉRIE:
- Médicaments courants: Doliprane, Aspégic, Spasfon, Efferalgan, Imodium
- Spécialités médicales disponibles: Médecine Générale, Pédiatrie, Cardiologie, etc.

FORMAT DE RÉPONSE:
- Symptômes décrits: [résume]
- Cause possible: [explication simple]
- Recommandation: [médicament OTC OU consultation médicale]
- Urgence: [faible/moyenne/élevée]

Si on te demande sur un médicament spécifique:
- Explique son utilité
- Donne la posologie générale
- Mentionne les précautions
- Rappelle de lire la notice

IMPORTANT: Tu dois toujours mentionner que tes conseils ne remplacent pas l'avis d'un professionnel de santé.
'''),
    );

    return this;
  }

  /// Send a medical query to AI
  /// Returns AI response as string
  Future<String> sendQuery(String query) async {
    try {
      final content = [Content.text(query)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return 'Désolé, je n\'ai pas pu générer une réponse. Veuillez réessayer.';
      }

      return response.text!;
    } catch (e) {
      print('AI Service Error: $e');

      // Friendly error messages
      if (e.toString().contains('API key')) {
        return 'Erreur: Clé API non configurée. Veuillez contacter l\'administrateur.';
      } else if (e.toString().contains('quota')) {
        return 'Service temporairement indisponible. Veuillez réessayer plus tard.';
      } else if (e.toString().contains('network')) {
        return 'Erreur de connexion. Vérifiez votre internet.';
      }

      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  /// Get suggestions for medication search based on symptoms
  Future<List<String>> getMedicationSuggestions(String symptoms) async {
    try {
      final query = '''
Symptômes: $symptoms

Liste uniquement les noms de médicaments en vente libre disponibles en Algérie pour ces symptômes.
Format: un médicament par ligne, maximum 5 médicaments.
Ne mets AUCUN autre texte, juste les noms.
''';

      final response = await sendQuery(query);

      // Parse response into list
      return response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(5)
          .toList();
    } catch (e) {
      print('Medication suggestions error: $e');
      return [];
    }
  }

  /// Check if two medications can be taken together
  Future<String> checkDrugInteraction(String med1, String med2) async {
    final query = '''
Est-ce que $med1 et $med2 peuvent être pris ensemble sans danger?

Réponds de manière concise avec:
1. OUI ou NON
2. Une explication courte
3. Les précautions si applicable
''';

    return await sendQuery(query);
  }

  /// Get information about a specific medication
  Future<String> getMedicationInfo(String medicationName) async {
    final query = '''
Donne-moi des informations sur le médicament: $medicationName

Inclus:
- À quoi il sert
- Posologie typique
- Précautions importantes
- Effets secondaires courants

Reste concis (4-5 lignes maximum).
''';

    return await sendQuery(query);
  }

  /// Suggest which medical specialty to consult
  Future<String> suggestSpecialty(String symptoms) async {
    final query = '''
Pour ces symptômes: $symptoms

Quelle spécialité médicale consulter?
Choisis parmi: Médecine Générale, Pédiatrie, Cardiologie, Dermatologie, 
Gynécologie, ORL, Ophtalmologie, Dentiste, Psychiatrie, Neurologie.

Réponds avec UNE SEULE spécialité et une raison courte (1 phrase).
''';

    return await sendQuery(query);
  }
}
