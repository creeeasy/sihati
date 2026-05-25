import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/medication_history_model.dart';
import '../../../../core/models/allergy_model.dart';

class BilanTab extends GetView<MedicalRecordController> {
  const BilanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _buildLastConsultationCard()),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildStatCard(
                      icon: AppIcons.prescription,
                      count: controller.ordonnancesCount.value.toString(),
                      label: 'Ordonnances',
                      color: AppColors.primary,
                    )),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => _buildStatCard(
                      icon: AppIcons.medication,
                      count: controller.medicationsCount.value.toString(),
                      label: 'Médicaments',
                      color: AppColors.success,
                    )),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildStatCard(
                      icon: AppIcons.calendar,
                      count: controller.consultationsCount.value.toString(),
                      label: 'Consultations',
                      color: AppColors.warning,
                    )),
              ),
              const SizedBox(width: AppSpacing.md),
              /*  Expanded(
                child: Obx(() => _buildStatCard(
                      //icon: AppIcons.folder,
                      count: controller.documentsCount.value.toString(),
                      label: 'Documents',
                      color: AppColors.info,
                    )),
              ), */
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle('Allergies & Contre-indications'),
          const SizedBox(height: AppSpacing.md),
          _buildAllergiesCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle('Traitement en cours'),
          const SizedBox(height: AppSpacing.md),
          _buildCurrentMedicationsCard(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildLastConsultationCard() {
    final consultation = controller.lastConsultation.value;

    if (consultation == null) {
      return Container(
        padding: AppSpacing.paddingCard,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Center(
          child: Text(
            'Aucune consultation récente',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppSpacing.cardRadius,
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(AppIcons.history,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn),
                    width: 24,
                    height: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dernière consultation',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(consultation.formattedDate,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: AppSpacing.chipRadius,
                ),
                child: Text('Terminée',
                    style:
                        AppTextStyles.labelSmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SvgPicture.asset(AppIcons.doctor,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Text(consultation.doctor?.fullName ?? 'Médecin non spécifié',
                  style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          if (consultation.diagnosis != null) ...[
            Row(
              children: [
                SvgPicture.asset(AppIcons.heart,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary, BlendMode.srcIn)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(consultation.diagnosis!,
                      style: AppTextStyles.bodySmall),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(icon,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: 24,
                height: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(count,
              style: AppTextStyles.displayMedium
                  .copyWith(color: AppColors.textPrimary, fontSize: 28)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.headline);
  }

  Widget _buildAllergiesCard() {
    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.error50,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppIcons.warning,
                  colorFilter:
                      const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
                  width: 24,
                  height: 24),
              const SizedBox(width: 12),
              Text('Allergies déclarées',
                  style:
                      AppTextStyles.title.copyWith(color: AppColors.error700)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            if (controller.allergies.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Aucune allergie déclarée',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              );
            }
            return Column(
              children: controller.allergies.map((allergy) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildAllergyChip(allergy),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAllergyChip(Allergy allergy) {
    final severityColor = _getSeverityColor(allergy.severity);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        boxShadow: AppColors.shadowXs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: severityColor, width: 3)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(AppIcons.warning,
                colorFilter:
                    const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
                width: 18,
                height: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(allergy.allergyName,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.error700)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: AppSpacing.chipRadius,
              ),
              child: Text(allergy.formattedSeverity,
                  style:
                      AppTextStyles.labelSmall.copyWith(color: severityColor)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.severe:
        return AppColors.error;
      case AllergySeverity.moderate:
        return AppColors.warning;
      case AllergySeverity.mild:
        return AppColors.success;
    }
  }

  Widget _buildCurrentMedicationsCard() {
    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        children: [
          Obx(() {
            if (controller.currentMedications.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Aucun traitement en cours',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              );
            }
            return Column(
              children:
                  controller.currentMedications.asMap().entries.map((entry) {
                final medication = entry.value;
                return Column(
                  children: [
                    _buildMedicationItem(medication),
                    if (entry.key < controller.currentMedications.length - 1)
                      const Divider(height: 24, color: AppColors.borderLight),
                  ],
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(MedicationHistory medication) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medication.medicationName, style: AppTextStyles.title),
              const SizedBox(height: 4),
              Text(medication.dosage, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                '${medication.frequency} • ${medication.isContinuous ? 'En continu' : 'Jusqu\'au ${_formatEndDate(medication.endDate)}'}\nPrescrit par: ${medication.prescribedBy ?? 'Médecin'}',
                style:
                    AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        if (medication.progressPercentage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success50,
              borderRadius: AppSpacing.chipRadius,
            ),
            child: Text('${medication.progressPercentage!.toInt()}%',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.success700)),
          ),
      ],
    );
  }

  String _formatEndDate(DateTime? endDate) {
    if (endDate == null) return 'Date inconnue';
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }
}
