// lib/modules/medications/controllers/medication_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/pharmacy_with_stock.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/ai_repository.dart';
import '../../../core/models/medication_model.dart';

class MedicationDetailController extends GetxController {
  final MedicationRepository _medicationRepository;
  final AiRepository _aiRepository;

  MedicationDetailController({
    required MedicationRepository medicationRepository,
    required AiRepository aiRepository,
  })  : _medicationRepository = medicationRepository,
        _aiRepository = aiRepository;

  // ─── State ────────────────────────────────────────────────────

  final isLoading = true.obs;
  final hasError = false.obs;
  final medication = Rxn<MedicationModel>();
  final pharmacies = <PharmacyWithStock>[].obs;
  final errorMessage = ''.obs;

  final interactionController = TextEditingController();
  final isCheckingInteraction = false.obs;
  final interactionResult = ''.obs;

  final questionController = TextEditingController();
  final isAskingAi = false.obs;
  final aiAnswer = ''.obs;

  // ─── Getters ──────────────────────────────────────────────────

  String get medicationId => Get.parameters['id'] ?? '';

  // ─── Lifecycle ────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    if (medicationId.isNotEmpty) {
      loadMedicationDetails();
    } else {
      hasError.value = true;
      errorMessage.value = 'Aucun médicament spécifié';
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    interactionController.dispose();
    questionController.dispose();
    super.onClose();
  }

  // ─── Load Methods ─────────────────────────────────────────────

  Future<void> loadMedicationDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result =
          await _medicationRepository.getMedicationById(medicationId);
      medication.value = result;

      await loadNearbyPharmacies();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNearbyPharmacies() async {
    if (medication.value == null) return;

    try {
      final result = await _medicationRepository.getPharmaciesWithStock(
        medication.value!.id,
        useLocation: true,
        radius: 10,
      );
      pharmacies.value = result;
    } catch (e) {
      print('Error loading pharmacies: $e');
    }
  }

  // ─── Drug Interaction Checker ─────────────────────────────────

  Future<void> checkInteraction() async {
    final otherMed = interactionController.text.trim();
    if (otherMed.isEmpty) {
      Get.snackbar(
        'Attention',
        'Veuillez entrer le nom d\'un médicament',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isCheckingInteraction.value = true;
      interactionResult.value = '';

      final result = await _aiRepository.checkDrugInteractions(
        med1: medication.value?.name ?? '',
        med2: otherMed,
      );
      interactionResult.value = result;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de vérifier l\'interaction',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isCheckingInteraction.value = false;
    }
  }

  // ─── Ask AI ───────────────────────────────────────────────────

  Future<void> askAiQuestion() async {
    final question = questionController.text.trim();
    if (question.isEmpty) {
      Get.snackbar(
        'Attention',
        'Veuillez poser une question',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isAskingAi.value = true;
      aiAnswer.value = '';

      final answer = await _aiRepository.askMedicationQuestion(
        medicationName: medication.value?.name ?? '',
        question: question,
      );
      aiAnswer.value = answer;
      questionController.clear();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'obtenir une réponse',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isAskingAi.value = false;
    }
  }

  // ─── Share ────────────────────────────────────────────────────

  Future<void> shareMedication() async {
    final med = medication.value;
    if (med == null) return;

    final text = '''
💊 ${med.name}

📋 Description:
${med.description ?? 'Non disponible'}

🔴 Ordonnance requise: ${med.requiresPrescription ? 'OUI' : 'NON'}

⚠️ IMPORTANT: Ces informations sont à titre éducatif uniquement.
Consultez toujours un médecin ou pharmacien.

Partagé depuis Sihati 🏥
''';

    try {
      await Share.share(text, subject: 'Informations sur ${med.name}');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de partager',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Reminders ────────────────────────────────────────────────

  Future<void> setReminder() async {
    final result = await Get.dialog<List<TimeOfDay>>(
      _ReminderDialog(medicationName: medication.value?.name ?? ''),
    );

    if (result == null || result.isEmpty) return;

    Get.snackbar(
      '⏰ Rappels configurés',
      '${result.length} rappel(s) pour ${medication.value?.name ?? ''}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      duration: const Duration(seconds: 3),
    );
  }

  // ─── Retry ────────────────────────────────────────────────────

  Future<void> retry() async {
    if (medicationId.isNotEmpty) {
      await loadMedicationDetails();
    }
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
