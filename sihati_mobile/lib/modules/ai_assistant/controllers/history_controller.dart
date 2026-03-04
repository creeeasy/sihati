import 'package:get/get.dart';
import '../../../../core/services/ai_service.dart';

class ConversationHistoryItem {
  final int id;
  final String userMessage;
  final String aiResponse;
  final DateTime createdAt;
  final UrgencyLevel urgency;
  final String? suggestedSpecialty;
  final bool isSymptomRelated;
  final int medicationCount;

  ConversationHistoryItem.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        userMessage = j['userMessage'] ?? j['user_message'] ?? '',
        aiResponse = j['aiResponse'] ?? j['ai_response'] ?? '',
        createdAt = DateTime.parse(j['createdAt'] ?? j['created_at']),
        urgency = urgencyFromString(j['context']?['urgency']),
        suggestedSpecialty = j['context']?['suggestedSpecialty'],
        isSymptomRelated = j['context']?['isSymptomRelated'] ?? false,
        medicationCount = j['context']?['medicationCount'] ?? 0;
}

class HistoryController extends GetxController {
  final AIService aiService;

  HistoryController({required this.aiService});

  final conversations = <ConversationHistoryItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  // Search/filter state
  final searchQuery = ''.obs;
  final filterUrgency = Rx<UrgencyLevel?>(null);

  List<ConversationHistoryItem> get filtered {
    var list = conversations.toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((c) =>
              c.userMessage.toLowerCase().contains(q) ||
              c.aiResponse.toLowerCase().contains(q))
          .toList();
    }

    if (filterUrgency.value != null) {
      list = list.where((c) => c.urgency == filterUrgency.value).toList();
    }

    return list;
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
      final raw = await aiService.getHistory();
      conversations.value =
          raw.map((j) => ConversationHistoryItem.fromJson(j)).toList();
    } catch (e) {
      errorMessage.value = 'Impossible de charger l\'historique.';
      print('❌ HistoryController.loadHistory: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String q) => searchQuery.value = q;

  void setUrgencyFilter(UrgencyLevel? u) => filterUrgency.value = u;

  void clearFilters() {
    searchQuery.value = '';
    filterUrgency.value = null;
  }
}
