import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/medication_history_model.dart';

// ========================================
// TAB 3: HISTORIQUE MÉDICAMENTS
// ========================================

class HistoriqueMedicamentsTabContent extends GetView<MedicalRecordController> {
  const HistoriqueMedicamentsTabContent({super.key});

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
              SvgPicture.asset(
                AppIcons.medication,
                width: 80,
                height: 80,
                colorFilter: ColorFilter.mode(AppColors.primary.withOpacity(0.3), BlendMode.srcIn),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aucun médicament',
                style: AppTextStyles.title.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Vos médicaments apparaîtront ici',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
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
                  color: AppColors.borderLight,
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
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
                          )),
                    ),
                    TextButton.icon(
                      icon: SvgPicture.asset(AppIcons.download, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                      label: Text('Exporter', style: AppTextStyles.labelLarge),
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
                                      : AppColors.borderDefault,
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
                                  Expanded(
                                    child: Text(
                                      'Afficher seulement les traitements en cours',
                                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                                      maxLines: 2,
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
                        SvgPicture.asset(
                          AppIcons.verified,
                          width: 64,
                          height: 64,
                          colorFilter: ColorFilter.mode(AppColors.success.withOpacity(0.5), BlendMode.srcIn),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          controller.showActiveOnly.value
                              ? 'Aucun traitement en cours'
                              : 'Aucun médicament dans l\'historique',
                          style: AppTextStyles.title.copyWith(color: AppColors.textSecondary),
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
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: isOngoing
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.borderDefault,
          width: isOngoing ? 2 : 1,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: AppSpacing.paddingCard,
            decoration: BoxDecoration(
              color:
                  isOngoing ? AppColors.primarySoft : AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                topRight: Radius.circular(AppSpacing.radiusLg),
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
                  child: SvgPicture.asset(
                    AppIcons.medication,
                    colorFilter: ColorFilter.mode(
                      isOngoing ? AppColors.primary : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.medicationName,
                        style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      // Get medication type/category if available
                      Text(
                        _getMedicationType(med),
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isOngoing ? AppColors.primary : AppColors.textSecondary,
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    isOngoing ? 'En cours' : 'Terminé',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: AppSpacing.paddingCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dosage
                _buildInfoRow(
                  AppIcons.medicalRecord,
                  'Posologie',
                  med.dosage,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Frequency
                _buildInfoRow(
                  AppIcons.history,
                  'Fréquence',
                  med.frequency,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Dates
                _buildInfoRow(
                  AppIcons.calendar,
                  'Période',
                  _formatDateRange(med),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Reason
                if (med.reason != null && med.reason!.isNotEmpty)
                  _buildInfoRow(
                    AppIcons.info,
                    'Raison',
                    med.reason!,
                  ),

                const SizedBox(height: AppSpacing.sm),

                // Prescribed by
                if (med.prescribedBy != null && med.prescribedBy!.isNotEmpty)
                  _buildInfoRow(
                    AppIcons.doctor,
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
                      borderRadius: AppSpacing.inputRadius,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.history,
                          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Traitement continu',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
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

  Widget _buildInfoRow(String icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
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
            Text(
              'Progression',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              daysLeft > 0 ? '$daysLeft jours restants' : 'Terminé',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.borderLight,
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
