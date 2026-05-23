import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/ai_models.dart';
import '../../../../data/repositories/ai_repository.dart';
import '../../../../app/routes/app_routes.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatResponse? aiResponse;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.aiResponse,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIAssistantController extends GetxController {
  final AiRepository aiRepository;
  AIAssistantController({required this.aiRepository});

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final _history = <HistoryItem>[];
  final textController = TextEditingController();

  // ScrollController lives here — owned by the controller, not the widget
  // so it survives widget rebuilds cleanly
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : null;

    if (args != null && args.containsKey('conversationId')) {
      _addWelcomeMessage();
      _loadAndResume(args['conversationId'] as String);
    } else {
      _addWelcomeMessage();
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ─── Resume conversation by id ────────────────────────────

  Future<void> _loadAndResume(String conversationId) async {
    isLoading.value = true;

    final conv = await aiRepository.getConversation(conversationId);
    isLoading.value = false;

    if (conv == null) {
      messages.add(ChatMessage(
        text: 'Impossible de charger cette conversation.',
        isUser: false,
      ));
      return;
    }

    final userMsg =
        conv['userMessage'] as String? ?? conv['user_message'] as String? ?? '';
    final aiReply =
        conv['aiResponse'] as String? ?? conv['ai_response'] as String? ?? '';

    // Inject into Gemini history for context
    _history.add(HistoryItem(role: 'user', text: userMsg));
    if (aiReply.isNotEmpty) {
      _history.add(HistoryItem(role: 'model', text: aiReply));
    }

    // Replace welcome message with the restored exchange
    messages.clear();
    messages.add(ChatMessage(text: userMsg, isUser: true));
    if (aiReply.isNotEmpty) {
      messages.add(ChatMessage(text: aiReply, isUser: false));
    }
    messages.add(ChatMessage(
      text: '↩️ Conversation reprise. Posez votre question suivante.',
      isUser: false,
    ));

    _scrollToBottom();
  }

  // ─── Send message ─────────────────────────────────────────

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();
    _scrollToBottom();

    _history.add(HistoryItem(role: 'user', text: text));
    isLoading.value = true;

    try {
      final responseMap = await aiRepository.chat(
        message: text,
        history: _history.map((h) => h.toJson()).toList(),
      );
      final response = ChatResponse.fromJson(responseMap);
      _history.add(HistoryItem(role: 'model', text: response.reply));
      if (_history.length > 40) _history.removeRange(0, 2);
      messages.add(ChatMessage(
        text: response.reply,
        isUser: false,
        aiResponse: response,
      ));
    } catch (e) {
      if (_history.isNotEmpty) _history.removeLast();
      messages.add(ChatMessage(
        text: 'Désolé, une erreur est survenue. Veuillez réessayer.',
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void sendQuickMessage(String text) {
    textController.text = text;
    sendMessage();
  }

  void searchMedication(String name) {
    Get.toNamed(AppRoutes.MEDICATION_SEARCH, arguments: {'searchQuery': name});
  }

  void clearChat() {
    Get.dialog(AlertDialog(
      title: const Text('Effacer la conversation'),
      content: const Text(
          'Voulez-vous supprimer tout l\'historique de cette conversation ?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            messages.clear();
            _history.clear();
            _addWelcomeMessage();
            Get.back();
            Get.snackbar('Effacé', 'Conversation supprimée',
                snackPosition: SnackPosition.BOTTOM);
          },
          child: const Text('Effacer'),
        ),
      ],
    ));
  }

  // ─── Private helpers ──────────────────────────────────────

  void _addWelcomeMessage() {
    messages.add(ChatMessage(
      text: '''Bonjour! 👋 Je suis votre assistant santé Sihati.

Je peux vous aider avec:
• Conseils pour vos symptômes
• Informations sur les médicaments
• Suggestions de spécialistes à consulter
• Vérification d\'interactions médicamenteuses

Comment puis-je vous aider aujourd\'hui?

⚠️ Rappel: Mes conseils ne remplacent pas l\'avis d\'un médecin.''',
      isUser: false,
    ));
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

  final quickSymptoms = const [
    "J'ai mal à la tête",
    "J'ai de la fièvre",
    "J'ai mal au ventre",
    "J'ai la grippe",
    "J'ai une toux",
  ];
}
