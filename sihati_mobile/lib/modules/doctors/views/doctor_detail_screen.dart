import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import '../controllers/doctor_detail_controller.dart';

class DoctorDetailScreen extends GetView<DoctorDetailController> {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadDoctorDetails,
          );
        }
        if (controller.doctor.value == null) {
          return const Center(
            child: Text('Médecin non trouvé'),
          );
        }
        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    final doctor = controller.doctor.value!;

    return CustomScrollView(
      slivers: [
        // App Bar with image placeholder
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Dr. ${doctor.doctorName.split(' ').last}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              color: AppColors.primary.withOpacity(0.7),
              child: Center(
                child: Text(
                  _getInitials(doctor.doctorName),
                  style: const TextStyle(
                    fontSize: 60,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Obx(
                () => Icon(
                  controller.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
              onPressed: controller.toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: controller.shareDoctor,
            ),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Name and specialty
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDoctorName(doctor.doctorName),
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doctor.specialty.nameFr,
                            style: AppTextStyles.subtitle2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  if (doctor.averageRating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 20,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.averageRating!.toStringAsFixed(1),
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          if (doctor.totalReviews != null)
                            Text(
                              '${doctor.totalReviews} avis',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Action buttons row
              _buildActionButtons(),

              const SizedBox(height: 24),

              // About section
              if (doctor.bio != null) ...[
                _buildSectionTitle('À propos'),
                const SizedBox(height: 8),
                Text(
                  doctor.bio!,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
              ],

              // Experience and fee
              _buildInfoRow(
                icon: Icons.work_outline,
                label: 'Expérience',
                value: doctor.yearsOfExperience != null
                    ? '${doctor.yearsOfExperience} ans'
                    : 'Non spécifié',
                color: AppColors.info,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.attach_money,
                label: 'Consultation',
                value: controller.formattedFee,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              if (doctor.distance != null)
                _buildInfoRow(
                  icon: Icons.near_me,
                  label: 'Distance',
                  value: '${doctor.distance!.toStringAsFixed(1)} km',
                  color: AppColors.primary,
                ),

              const SizedBox(height: 20),

              // Clinic information
              _buildSectionTitle('Cabinet médical'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    if (doctor.clinicName != null)
                      Row(
                        children: [
                          Icon(
                            Icons.business_center,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              doctor.clinicName!,
                              style: AppTextStyles.subtitle2,
                            ),
                          ),
                        ],
                      ),
                    if (doctor.clinicName != null) const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.clinicAddress,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.fullAddress,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Obtenir l\'itinéraire',
                      onPressed: controller.getDirections,
                      isOutlined: true,
                      icon: Icons.directions,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Working hours
              _buildSectionTitle('Horaires de travail'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Obx(
                  () {
                    final hours = controller.workingHoursList;
                    if (hours.isEmpty) {
                      return Text(
                        'Horaires non spécifiés',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    return Column(
                      children: hours.map((entry) {
                        final isToday = _isToday(entry.key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  entry.key,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isToday
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isToday
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Contact section
              _buildSectionTitle('Contact'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildContactTile(
                      icon: Icons.phone,
                      label: 'Téléphone',
                      value: doctor.phone,
                      color: AppColors.primary,
                      onTap: controller.callDoctor,
                    ),
                    if (doctor.whatsappNumber != null &&
                        doctor.whatsappNumber!.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildContactTile(
                        icon: Icons.message,
                        label: 'WhatsApp',
                        value: doctor.whatsappNumber!,
                        color: const Color(0xFF25D366),
                        onTap: controller.openWhatsApp,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Appeler',
            onPressed: controller.callDoctor,
            icon: Icons.phone,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'WhatsApp',
            onPressed: controller.openWhatsApp,
            isOutlined: true,
            icon: Icons.message,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h5,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatDoctorName(String name) {
    if (name.startsWith('Dr') || name.startsWith('DR')) {
      return name;
    }
    return 'Dr. $name';
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekDays = {
      'Lundi': 1,
      'Mardi': 2,
      'Mercredi': 3,
      'Jeudi': 4,
      'Vendredi': 5,
      'Samedi': 6,
      'Dimanche': 7,
    };
    final todayIndex = now.weekday; // 1 = Monday, 7 = Sunday
    return weekDays[day] == todayIndex;
  }
}
