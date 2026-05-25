import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/prescription_model.dart';

// ========================================
// TAB 2: ORDONNANCES
// ========================================

class OrdonnancesTabContent extends GetView<MedicalRecordController> {
  const OrdonnancesTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.prescriptions.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      if (controller.prescriptions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.prescription,
                width: 80,
                height: 80,
                colorFilter: ColorFilter.mode(
                    AppColors.primary.withOpacity(0.3), BlendMode.srcIn),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aucune ordonnance',
                style: AppTextStyles.title
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Vos ordonnances apparaîtront ici',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => controller.refreshData(),
        color: AppColors.primary,
        child: Column(
          children: [
            // Filter/Sort bar
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${controller.prescriptions.length} ordonnances',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: controller.prescriptions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final prescription = controller.prescriptions[index];
                  return _buildOrdonnanceCard(prescription);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOrdonnanceCard(Prescription prescription) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1.5,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: AppSpacing.paddingCard,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                topRight: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.prescription,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn),
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
                        _formatDate(prescription.prescriptionDate),
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prescription.doctor?.doctorName ?? 'Médecin',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (prescription.fileUrl != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success50,
                      borderRadius: AppSpacing.chipRadius,
                    ),
                    child: SvgPicture.asset(
                      AppIcons.verified,
                      colorFilter: const ColorFilter.mode(
                          AppColors.success, BlendMode.srcIn),
                      width: 20,
                      height: 20,
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
                // Specialty
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.doctor,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                          AppColors.textSecondary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prescription.doctor?.specialty?.nameFr ??
                          'Spécialité non spécifiée',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Medications
                Text(
                  'Médicaments prescrits',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textPrimary),
                ),

                const SizedBox(height: 8),

                ...prescription.medications
                    .map((med) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med.medicationName,
                                      style: AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.textPrimary),
                                    ),
                                    if (med.dosage != null ||
                                        med.frequency != null)
                                      Text(
                                        _formatMedicationDetails(med),
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                    if (med.durationDays != null)
                                      Text(
                                        'Durée: ${med.durationDays} jours',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(color: AppColors.primary),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                // Expiry warning
                if (prescription.isExpired && !prescription.isRenewable)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error50,
                      borderRadius: AppSpacing.inputRadius,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.warning,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                              AppColors.error, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ordonnance expirée depuis le ${_formatDate(prescription.expiryDate)}',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.error700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Notes
                if (prescription.notes != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      //color: AppColors.info50,
                      borderRadius: AppSpacing.inputRadius,
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppIcons.info,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                              AppColors.info, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prescription.notes!,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMedicationDetails(PrescriptionMedication med) {
    final details = <String>[];
    if (med.dosage != null && med.dosage!.isNotEmpty) {
      details.add(med.dosage!);
    }
    if (med.frequency != null && med.frequency!.isNotEmpty) {
      details.add(med.frequency!);
    }
    return details.join(' - ');
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
