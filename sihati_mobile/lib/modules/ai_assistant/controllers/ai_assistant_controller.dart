import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../data/repositories/medication_repository.dart';

/// Message model for chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? medicationSuggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.medicationSuggestions,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// AI Assistant Controller
class AIAssistantController extends GetxController {
  final AIService aiService;
  final MedicationRepository? medicationRepository;

  AIAssistantController({
    required this.aiService,
    this.medicationRepository,
  });

  // State
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _addWelcomeMessage() {
    messages.add(ChatMessage(
      text: '''Bonjour! 👋 Je suis votre assistant santé Sihati.

Je peux vous aider avec:
• Conseils pour vos symptômes
• Informations sur les médicaments
• Suggestions de spécialistes à consulter
• Vérification d'interactions médicamenteuses

Comment puis-je vous aider aujourd'hui?

⚠️ Rappel: Mes conseils ne remplacent pas l'avis d'un médecin.''',
      isUser: false,
    ));
  }

  /// Send user message and get AI response
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Show loading
    isLoading.value = true;

    try {
      // Get AI response
      final response = await aiService.sendQuery(text);

      // Check if query is about symptoms - suggest medications
      List<String>? suggestions;
      if (_isSymptomQuery(text)) {
        suggestions = await aiService.getMedicationSuggestions(text);
      }

      // Add AI response
      messages.add(ChatMessage(
        text: response,
        isUser: false,
        medicationSuggestions: suggestions,
      ));

      _scrollToBottom();
    } catch (e) {
      messages.add(ChatMessage(
        text: 'Désolé, une erreur est survenue. Veuillez réessayer.',
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }

  /// Quick action: Check drug interaction
  Future<void> checkInteraction(String med1, String med2) async {
    textController.text = 'Puis-je prendre $med1 avec $med2 ?';
    await sendMessage();
  }

  /// Quick action: Get medication info
  Future<void> getMedicationInfo(String medicationName) async {
    textController.text = 'C\'est quoi $medicationName ?';
    await sendMessage();
  }

  /// Navigate to medication search with AI suggestion
  void searchMedication(String medicationName) {
    Get.toNamed(
      AppRoutes.MEDICATION_SEARCH,
      arguments: {'searchQuery': medicationName},
    );
  }

  /// Clear chat history
  void clearChat() {
    Get.dialog(
      AlertDialog(
        title: const Text('Effacer la conversation'),
        content: const Text(
          'Voulez-vous supprimer tout l\'historique de cette conversation ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              messages.clear();
              _addWelcomeMessage();
              Get.back();
              Get.snackbar(
                'Effacé',
                'Conversation supprimée',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isSymptomQuery(String text) {
    final symptomKeywords = [
      'mal',
      'douleur',
      'fièvre',
      'toux',
      'rhume',
      'grippe',
      'maux',
      'symptom',
      'souffre',
      'malade',
      'fatigue',
    ];

    return symptomKeywords
        .any((keyword) => text.toLowerCase().contains(keyword));
  }

  /// Quick symptom suggestions
  final quickSymptoms = [
    'J\'ai mal à la tête',
    'J\'ai de la fièvre',
    'J\'ai mal au ventre',
    'J\'ai la grippe',
    'J\'ai une toux',
  ];
}
