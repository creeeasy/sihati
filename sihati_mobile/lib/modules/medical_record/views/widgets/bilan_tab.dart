import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/medication_history_model.dart';
import '../../../../core/models/allergy_model.dart';

class BilanTab extends GetView<MedicalRecordController> {
  const BilanTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dernière consultation
          Obx(() => _buildLastConsultationCard()),

          const SizedBox(height: AppSpacing.lg),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildStatCard(
                      icon: Icons.description_outlined,
                      count: controller.ordonnancesCount.value.toString(),
                      label: 'Ordonnances',
                      color: AppColors.primary,
                    )),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => _buildStatCard(
                      icon: Icons.medication_outlined,
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
                      icon: Icons.calendar_today_outlined,
                      count: controller.consultationsCount.value.toString(),
                      label: 'Consultations',
                      color: AppColors.warning,
                    )),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => _buildStatCard(
                      icon: Icons.folder_outlined,
                      count: controller.documentsCount.value.toString(),
                      label: 'Documents',
                      color: AppColors.info,
                    )),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Section Allergies
          _buildSectionTitle('Allergies & Contre-indications'),
          const SizedBox(height: AppSpacing.md),
          _buildAllergiesCard(),

          const SizedBox(height: AppSpacing.lg),

          // Médicaments en cours
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Aucune consultation récente',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primarySoft,
            AppColors.primarySoft.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
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
                child: const Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dernière consultation',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      consultation.formattedDate,
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
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Terminée',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                consultation.doctor?.fullName ?? 'Médecin non spécifié',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Consultation médicale',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (consultation.diagnosis != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.healing,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    consultation.diagnosis!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text('Voir ordonnance'),
                  onPressed: () {
                    // TODO: Navigate to prescription detail
                    Get.snackbar(
                      'Info',
                      'Fonctionnalité à venir',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
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
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAllergiesCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.errorLight,
            AppColors.errorLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Allergies déclarées',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            if (controller.allergies.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Aucune allergie déclarée',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textSecondary,
                    ),
                  ),
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
          const SizedBox(height: AppSpacing.md),
          // NOTE: addAllergy removed — /patient/allergies is read-only.
          // Use a dedicated allergy management screen with /allergies endpoint.
        ],
      ),
    );
  }

  Widget _buildAllergyChip(Allergy allergy) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              allergy.allergyName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.errorDark,
              ),
            ),
          ),
          if (allergy.severity != AllergySeverity.mild || true)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getSeverityByEnum(allergy.severity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                allergy.formattedSeverity,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getSeverityByEnum(allergy.severity),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSeverityByEnum(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.severe:
        return Colors.red;
      case AllergySeverity.moderate:
        return Colors.orange;
      case AllergySeverity.mild:
        return Colors.green;
    }
  }

  // Legacy string-based version kept for compatibility
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
        return Colors.green;
      default:
        return AppColors.error;
    }
  }

  Widget _buildCurrentMedicationsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Obx(() {
            if (controller.currentMedications.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Aucun traitement en cours',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textSecondary,
                    ),
                  ),
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
                      const Divider(height: 24),
                  ],
                );
              }).toList(),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter un médicament'),
            onPressed: controller.addMedication,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
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
              Text(
                medication.medicationName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medication.dosage,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${medication.frequency} • ${medication.isContinuous ? 'En continu' : 'Jusqu\'au ${_formatEndDate(medication.endDate)}'}\nPrescrit par: ${medication.prescribedBy ?? 'Médecin'}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (medication.progressPercentage != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${medication.progressPercentage!.toInt()}%',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ),
      ],
    );
  }

  String _formatEndDate(DateTime? endDate) {
    if (endDate == null) return 'Date inconnue';
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }
}
