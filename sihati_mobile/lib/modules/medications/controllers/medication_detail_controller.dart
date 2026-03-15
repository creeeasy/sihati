import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/services/notification_service.dart';

class MedicationDetailController extends GetxController {
  final AIService aiService;
  final StorageService? storageService;
  final FavoritesService? favoritesService;
  final NotificationService? notificationService;

  MedicationDetailController({
    required this.aiService,
    this.storageService,
    this.favoritesService,
    this.notificationService,
  });

  // ─── State ────────────────────────────────────────────────────

  final isLoading = true.obs;
  final hasError = false.obs;
  final info = Rxn<MedicationInfoResponse>();
  final isFavorite = false.obs;

  // Drug interaction checker
  final interactionController = TextEditingController();
  final isCheckingInteraction = false.obs;
  final interactionResult = ''.obs;

  // Ask AI
  final questionController = TextEditingController();
  final isAskingAi = false.obs;
  final aiAnswer = ''.obs;

  // ─── Getters ──────────────────────────────────────────────────

  String get medicationName {
    final args = Get.arguments;
    if (args is Map) return args['medicationName'] as String? ?? '';
    return args?.toString() ?? '';
  }

  // ─── Lifecycle ────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadMedicationInfo();
    _syncFavoriteState();
    _saveToHistory();
  }

  @override
  void onClose() {
    interactionController.dispose();
    questionController.dispose();
    super.onClose();
  }

  // ─── Load ─────────────────────────────────────────────────────

  Future<void> loadMedicationInfo() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      info.value = await aiService.getMedicationInfo(medicationName);
    } catch (e) {
      hasError.value = true;
      Get.snackbar('Erreur', 'Impossible de charger les informations',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() => loadMedicationInfo();

  // ─── Favorites — uses FavoritesService pattern ────────────────

  void _syncFavoriteState() {
    if (favoritesService == null) return;
    // Keep isFavorite in sync with FavoritesService observable list
    isFavorite.value = favoritesService!.isMedicationFavorite(medicationName);
    ever(favoritesService!.favoriteMedications, (_) {
      isFavorite.value = favoritesService!.isMedicationFavorite(medicationName);
    });
  }

  Future<void> toggleFavorite() async {
    if (favoritesService == null) {
      Get.snackbar('Non disponible',
          'La fonctionnalité favoris n\'est pas encore configurée',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // FavoritesService handles toggle + snackbar internally
    await favoritesService!.toggleMedicationFavorite(medicationName);
  }

  // ─── Reminders ────────────────────────────────────────────────

  Future<void> setReminder() async {
    final result = await Get.dialog<List<TimeOfDay>>(
      _ReminderDialog(medicationName: medicationName),
    );

    if (result == null || result.isEmpty) return;

    if (notificationService == null) {
      Get.snackbar(
          'Non disponible', 'Les notifications ne sont pas encore configurées',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await notificationService!.scheduleMedicationReminders(
        medicationName: medicationName,
        times: result,
      );
      Get.snackbar('⏰ Rappels configurés',
          '${result.length} rappel(s) pour $medicationName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[900],
          duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de configurer les rappels',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100]);
    }
  }

  // ─── Share ────────────────────────────────────────────────────

  Future<void> shareMedication() async {
    if (info.value == null) return;

    final text = '''
💊 $medicationName

📋 Indications:
${info.value!.usage}

🚫 Contre-indications:
${info.value!.contraindications}

⚖️ Posologie:
${info.value!.dosage}

⚠️ Effets secondaires:
${info.value!.sideEffects}

⚠️ IMPORTANT: Ces informations sont à titre éducatif uniquement.
Consultez toujours un médecin ou pharmacien.

Partagé depuis Sihati 🏥
''';

    try {
      await Share.share(text, subject: 'Informations sur $medicationName');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de partager',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Drug Interaction Checker ─────────────────────────────────

  Future<void> checkInteraction() async {
    final otherMed = interactionController.text.trim();
    if (otherMed.isEmpty) {
      Get.snackbar('Attention', 'Veuillez entrer le nom d\'un médicament',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isCheckingInteraction.value = true;
      interactionResult.value = '';
      final result = await aiService.checkDrugInteraction(
        medication1: medicationName,
        medication2: otherMed,
      );
      interactionResult.value = result;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de vérifier l\'interaction',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100]);
    } finally {
      isCheckingInteraction.value = false;
    }
  }

  // ─── Ask AI ───────────────────────────────────────────────────

  Future<void> askAiQuestion() async {
    final question = questionController.text.trim();
    if (question.isEmpty) {
      Get.snackbar('Attention', 'Veuillez poser une question',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isAskingAi.value = true;
      aiAnswer.value = '';
      final answer = await aiService.askMedicationQuestion(
        medicationName: medicationName,
        question: question,
      );
      aiAnswer.value = answer;
      questionController.clear();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'obtenir une réponse',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100]);
    } finally {
      isAskingAi.value = false;
    }
  }

  // ─── History ──────────────────────────────────────────────────

  Future<void> _saveToHistory() async {
    if (storageService == null) return;
    await storageService!.addToMedicationHistory({
      'name': medicationName,
      'viewedAt': DateTime.now().toIso8601String(),
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// Reminder Dialog
// ═══════════════════════════════════════════════════════════════

class _ReminderDialog extends StatefulWidget {
  final String medicationName;
  const _ReminderDialog({required this.medicationName});

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  final List<TimeOfDay> selectedTimes = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.alarm,
                      color: Color(0xFF1A73E8), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Rappels de prise',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.medicationName,
                style: const TextStyle(
                    color: Color(0xFF1A73E8), fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            if (selectedTimes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: Text('Aucun rappel configuré',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...selectedTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF1A73E8)),
                      const SizedBox(width: 12),
                      Text(time.format(context),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () =>
                            setState(() => selectedTimes.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un horaire'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedTimes.isEmpty
                        ? null
                        : () => Navigator.pop(context, selectedTimes),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A73E8)),
        ),
        child: child!,
      ),
    );
    if (time != null) {
      setState(() {
        selectedTimes.add(time);
        selectedTimes.sort((a, b) =>
            (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      });
    }
  }
}
