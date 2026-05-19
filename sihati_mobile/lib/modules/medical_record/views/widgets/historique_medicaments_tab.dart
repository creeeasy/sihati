import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/medication_history_model.dart';

// ========================================
// TAB 3: HISTORIQUE MÉDICAMENTS
// ========================================

class HistoriqueMedicamentsTabContent extends GetView<MedicalRecordController> {
  const HistoriqueMedicamentsTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.medicationHistory.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      if (controller.medicationHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medication_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Aucun médicament',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Vos médicaments apparaîtront ici',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(
                            '${_getFilteredMedications().length} médicaments',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          )),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text('Exporter'),
                      onPressed: _exportMedicationHistory,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Toggle active only
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => GestureDetector(
                            onTap: () {
                              controller.showActiveOnly.toggle();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: controller.showActiveOnly.value
                                    ? AppColors.primarySoft
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: controller.showActiveOnly.value
                                      ? AppColors.primary.withOpacity(0.3)
                                      : AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    controller.showActiveOnly.value
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: controller.showActiveOnly.value
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Afficher seulement les traitements en cours',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => Switch(
                          value: controller.showActiveOnly.value,
                          onChanged: (value) {
                            controller.showActiveOnly.value = value;
                          },
                          activeColor: AppColors.primary,
                        )),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => controller.refreshData(),
              color: AppColors.primary,
              child: Obx(() {
                final filteredMeds = _getFilteredMedications();
                if (filteredMeds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.success.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          controller.showActiveOnly.value
                              ? 'Aucun traitement en cours'
                              : 'Aucun médicament dans l\'historique',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filteredMeds.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final medication = filteredMeds[index];
                    return _buildMedicationCard(medication);
                  },
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  List<MedicationHistory> _getFilteredMedications() {
    if (controller.showActiveOnly.value) {
      return controller.medicationHistory
          .where((m) => m.isContinuous || (m.endDate != null && m.endDate!.isAfter(DateTime.now())))
          .toList();
    }
    return controller.medicationHistory;
  }

  Widget _buildMedicationCard(MedicationHistory med) {
    final isOngoing = med.isContinuous || (med.endDate != null && med.endDate!.isAfter(DateTime.now()));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOngoing
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: isOngoing ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:
                  isOngoing ? AppColors.primarySoft : AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOngoing
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: isOngoing
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.medicationName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Get medication type/category if available
                      Text(
                        _getMedicationType(med),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                    child: Text(
                    isOngoing ? 'En cours' : 'Terminé',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dosage
                _buildInfoRow(
                  Icons.access_time,
                  'Posologie',
                  med.dosage,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Frequency
                _buildInfoRow(
                  Icons.repeat,
                  'Fréquence',
                  med.frequency,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Dates
                _buildInfoRow(
                  Icons.calendar_today,
                  'Période',
                  _formatDateRange(med),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Reason
                if (med.reason != null && med.reason!.isNotEmpty)
                  _buildInfoRow(
                    Icons.note_outlined,
                    'Raison',
                    med.reason!,
                  ),

                const SizedBox(height: AppSpacing.sm),

                // Prescribed by
                if (med.prescribedBy != null && med.prescribedBy!.isNotEmpty)
                  _buildInfoRow(
                    Icons.person_outline,
                    'Prescrit par',
                    med.prescribedBy!,
                  ),

                if (isOngoing && med.endDate != null) ...[
                  const SizedBox(height: AppSpacing.md),

                  // Progress bar
                  _buildProgressBar(med),
                ],

                if (isOngoing && med.endDate == null) ...[
                  const SizedBox(height: AppSpacing.md),

                  // Continuous treatment indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.all_inclusive,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Traitement continu',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(MedicationHistory med) {
    final daysLeft = med.daysRemaining ?? 0;
    final progress = med.progressPercentage ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progression',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              daysLeft > 0 ? '$daysLeft jours restants' : 'Terminé',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _getMedicationType(MedicationHistory med) {
    // Try to extract type from medication name or use default
    final name = med.medicationName.toLowerCase();
    if (name.contains('doliprane') || name.contains('paracétamol')) {
      return 'Antalgique';
    } else if (name.contains('amoxicilline') || name.contains('antibiotique')) {
      return 'Antibiotique';
    } else if (name.contains('aspirine')) {
      return 'Anti-coagulant';
    } else if (name.contains('ibuprofène')) {
      return 'Anti-inflammatoire';
    }
    return 'Médicament';
  }

  String _formatDateRange(MedicationHistory med) {
    final start = _formatDate(med.startDate);
    if (med.endDate != null) {
      return '$start - ${_formatDate(med.endDate!)}';
    }
    return '$start - En continu';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _exportMedicationHistory() async {
    try {
      // TODO: Implement export functionality
      Get.snackbar(
        'Export',
        'Export de l\'historique médicamenteux',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter l\'historique',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
