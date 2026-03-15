import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/sihati_mapbox.dart';
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
          return const Center(child: Text('Médecin non trouvé'));
        }
        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    final doctor = controller.doctor.value!;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 4,
              child: SihatiMapbox(
                latitude: doctor.latitude,
                longitude: doctor.longitude,
                markerTitle: doctor.clinicName,
                height: double.infinity,
                zoom: 15,
              ),
            ),
            Expanded(
              flex: 6,
              child: _buildDetailsSheet(doctor),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(Get.context!).padding.top + 8,
          left: 8,
          child: _buildBackButton(),
        ),
        Positioned(
          top: MediaQuery.of(Get.context!).padding.top + 8,
          right: 8,
          child: Row(
            children: [
              _buildActionButton(
                icon: controller.isFavorite.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                onPressed: controller.toggleFavorite,
                color: controller.isFavorite.value ? Colors.red : null,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                onPressed: controller.shareDoctor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDetailsSheet(doctor) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    _getInitials(doctor.doctorName),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDoctorName(doctor.doctorName),
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doctor.specialty.nameFr,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (doctor.averageRating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              doctor.averageRating!.toStringAsFixed(1),
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (doctor.totalReviews != null)
                          Text(
                            '${doctor.totalReviews}',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Prendre Rendez-vous',
              icon: Icons.event,
              onPressed: controller.bookAppointment,
              height: 56,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Appeler',
                    icon: Icons.phone,
                    isOutlined: true,
                    onPressed: controller.callDoctor,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'WhatsApp',
                    icon: Icons.chat,
                    isOutlined: true,
                    onPressed: controller.openWhatsApp,
                    height: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.nextAvailableSlot.value != null) {
                return _buildNextSlotCard(controller.nextAvailableSlot.value!);
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: Icons.attach_money,
                    label: 'Consultation',
                    value: controller.formattedFee,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: Icons.work_outline,
                    label: 'Expérience',
                    value: doctor.yearsOfExperience != null
                        ? '${doctor.yearsOfExperience} ans'
                        : 'N/A',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: Icons.near_me,
                    label: 'Distance',
                    value: doctor.distance != null
                        ? '${doctor.distance!.toStringAsFixed(1)} km'
                        : 'N/A',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: Icons.location_city,
                    label: 'Wilaya',
                    value: doctor.wilaya,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildSectionTitle('À propos'),
              const SizedBox(height: 12),
              Text(
                doctor.bio!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionTitle('Cabinet médical'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (doctor.clinicName.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.business,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            doctor.clinicName,
                            style: AppTextStyles.subtitle2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 20, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.fullAddress,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Obtenir l\'itinéraire',
                    icon: Icons.directions,
                    isOutlined: true,
                    onPressed: controller.getDirections,
                    height: 44,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionTitle('Horaires de travail'),
            const SizedBox(height: 12),
            Obx(() {
              final hours = controller.workingHoursList;
              if (hours.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Horaires non spécifiés',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: hours.map((entry) {
                    final isToday = _isToday(entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              entry.key,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isToday ? AppColors.primary : Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isToday
                                    ? AppColors.primary
                                    : entry.value
                                            .toLowerCase()
                                            .contains('fermé')
                                        ? Colors.grey[600]
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildSectionTitle('Contact'),
            const SizedBox(height: 12),
            _buildContactTile(
              icon: Icons.phone,
              label: 'Téléphone',
              value: doctor.phone,
              color: AppColors.primary,
              onTap: controller.callDoctor,
            ),
            if (doctor.whatsappNumber != null &&
                doctor.whatsappNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildContactTile(
                icon: Icons.chat,
                label: 'WhatsApp',
                value: doctor.whatsappNumber!,
                color: const Color(0xFF25D366),
                onTap: controller.openWhatsApp,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSlotCard(String slot) {
    return InkWell(
      onTap: controller.bookAppointment,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.1),
              AppColors.success.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prochain créneau disponible',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot,
                    style: AppTextStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
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
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
    final todayIndex = now.weekday;
    return weekDays[day] == todayIndex;
  }
}
