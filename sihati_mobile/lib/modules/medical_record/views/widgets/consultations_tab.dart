import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/consultation_model.dart';

class ConsultationsTab extends GetView<MedicalRecordController> {
  const ConsultationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.consultations.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      if (controller.consultations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.consultation,
                width: 80,
                height: 80,
                colorFilter: ColorFilter.mode(AppColors.primary.withOpacity(0.3), BlendMode.srcIn),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Aucune consultation',
                style: AppTextStyles.title.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Vos consultations apparaîtront ici',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.refreshData(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: controller.consultations.length,
          itemBuilder: (context, index) {
            final consultation = controller.consultations[index];
            return _buildConsultationCard(consultation);
          },
        ),
      );
    });
  }

  Widget _buildConsultationCard(Consultation consultation) {
    final doctor = consultation.doctor;
    final isExpanded = false.obs;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppColors.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => isExpanded.toggle(),
          borderRadius: AppSpacing.cardRadius,
          child: Padding(
            padding: AppSpacing.paddingCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons.doctor,
                          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor?.fullName ?? 'Consultation médicale',
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Consultation médicale',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success50,
                        borderRadius: AppSpacing.chipRadius,
                      ),
                      child: Text(
                        consultation.formattedDate,
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.success700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Diagnostique (toujours visible)
                if (consultation.diagnosis != null) ...[
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.heart,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          consultation.diagnosis!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // Motif de consultation (toujours visible)
                if (consultation.chiefComplaint != null) ...[
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.medicalRecord,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          consultation.chiefComplaint!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],

                // Expandable content
                Obx(() {
                  if (!isExpanded.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: AppSpacing.lg, color: AppColors.borderLight),

                      // Traitement
                      if (consultation.treatmentPlan != null) ...[
                        Text(
                          'Traitement prescrit',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          consultation.treatmentPlan!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Notes
                      if (consultation.notes != null) ...[
                        Text(
                          'Notes du médecin',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          consultation.notes!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          softWrap: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  );
                }),

                // Expand/collapse indicator
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Obx(() => Icon(
                        isExpanded.value
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
