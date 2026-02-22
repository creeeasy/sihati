import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and specialty
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor avatar with initials
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(),
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and specialty
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDoctorName(doctor.doctorName),
                          style: AppTextStyles.subtitle1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            doctor.specialty.nameFr,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating if available
                  if (doctor.averageRating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.averageRating!.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (doctor.totalReviews != null)
                            Text(
                              ' (${doctor.totalReviews})',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Clinic info
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business_center_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doctor.clinicName,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Address
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.clinicAddress,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${doctor.wilaya}${doctor.commune != null ? ', ${doctor.commune}' : ''}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contact and info row
              Row(
                children: [
                  // Phone
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.phone,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Distance if available
                  if (doctor.distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.near_me,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.distance!.toStringAsFixed(1)} km',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Additional info row
              Row(
                children: [
                  // Consultation fee
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.consultationFee != null
                              ? '${doctor.consultationFee!.toStringAsFixed(0)} DA'
                              : 'Prix non spécifié',
                          style: AppTextStyles.caption.copyWith(
                            color: doctor.consultationFee != null
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: doctor.consultationFee != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Years of experience
                  if (doctor.yearsOfExperience != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 16,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.yearsOfExperience} ans',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  // Call button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone,
                      label: 'Appeler',
                      color: AppColors.primary,
                      onTap: () => _makePhoneCall(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // WhatsApp button (if available)
                  if (doctor.whatsappNumber != null &&
                      doctor.whatsappNumber!.isNotEmpty)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.message,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366), // WhatsApp green
                        onTap: () => _openWhatsApp(),
                      ),
                    ),

                  // Directions button
                  if (!(doctor.whatsappNumber != null &&
                      doctor.whatsappNumber!.isNotEmpty))
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.directions,
                        label: 'Itinéraire',
                        color: AppColors.secondary,
                        onTap: () => _openDirections(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final parts = doctor.doctorName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return doctor.doctorName.substring(0, 1).toUpperCase();
  }

  String _formatDoctorName(String name) {
    // Add "Dr." prefix if not already present
    if (name.startsWith('Dr') || name.startsWith('DR')) {
      return name;
    }
    return 'Dr. $name';
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall() {
    final phoneNumber = doctor.phone.replaceAll(' ', '');
    // Use URL launcher to make phone call
    // You'll need to add url_launcher dependency
    // launch('tel:$phoneNumber');
    print('Calling $phoneNumber');

    // Show snackbar as placeholder
    Get.snackbar(
      'Appel',
      'Fonctionnalité à implémenter: Appeler ${doctor.doctorName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openWhatsApp() {
    if (doctor.whatsappNumber != null) {
      final whatsappNumber = doctor.whatsappNumber!.replaceAll(' ', '');
      // Use URL launcher to open WhatsApp
      // launch('https://wa.me/$whatsappNumber?text=Bonjour%20Docteur');
      print('Opening WhatsApp for $whatsappNumber');

      // Show snackbar as placeholder
      Get.snackbar(
        'WhatsApp',
        'Fonctionnalité à implémenter: Ouvrir WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openDirections() {
    // Use URL launcher to open Google Maps
    // launch('https://www.google.com/maps/search/?api=1&query=${doctor.latitude},${doctor.longitude}');
    print('Opening directions to ${doctor.clinicAddress}');

    // Show snackbar as placeholder
    Get.snackbar(
      'Itinéraire',
      'Fonctionnalité à implémenter: Ouvrir Google Maps',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
