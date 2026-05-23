import 'package:get/get.dart';
import '../../../../data/repositories/ai_repository.dart';

class ConversationHistoryItem {
  final String id;
  final String userMessage;
  final String aiResponse;
  final DateTime createdAt;

  ConversationHistoryItem.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        userMessage = j['userMessage'] ?? j['user_message'] ?? '',
        aiResponse = j['aiResponse'] ?? j['ai_response'] ?? '',
        createdAt = DateTime.parse(j['createdAt'] ?? j['created_at']);
}

class HistoryController extends GetxController {
  final AiRepository aiRepository;

  HistoryController({required this.aiRepository});

  final conversations = <ConversationHistoryItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  final searchQuery = ''.obs;

  List<ConversationHistoryItem> get filtered {
    if (searchQuery.value.isEmpty) return conversations;
    final q = searchQuery.value.toLowerCase();
    return conversations
        .where((c) =>
            c.userMessage.toLowerCase().contains(q) ||
            c.aiResponse.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final raw = await aiRepository.getHistory();
      conversations.value =
          raw.map((j) => ConversationHistoryItem.fromJson(j)).toList();
    } catch (e) {
      errorMessage.value = 'Impossible de charger l\'historique.';
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String q) => searchQuery.value = q;
  void clearSearch() => searchQuery.value = '';
}
