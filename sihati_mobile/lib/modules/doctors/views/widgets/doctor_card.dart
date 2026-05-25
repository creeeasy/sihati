import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: AppColors.shadowSm,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.cardRadius,
          child: Padding(
            padding: AppSpacing.paddingCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(),
                          style: AppTextStyles.headline.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDoctorName(doctor.doctorName),
                            style: AppTextStyles.title,
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
                              color: AppColors.primarySoft,
                              borderRadius: AppSpacing.chipRadius,
                            ),
                            child: Text(
                              doctor.specialty?.nameFr ?? 'Spécialiste',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (doctor.averageRating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning100,
                          borderRadius: AppSpacing.chipRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.starFilled,
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(AppColors.warning, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor.averageRating!.toStringAsFixed(1),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                            if (doctor.totalReviews != null)
                              Text(
                                ' (${doctor.totalReviews})',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.warning700,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.hospital,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        AppIcons.location,
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
                              doctor.clinicAddress,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${doctor.wilaya}${doctor.commune != null ? ', ${doctor.commune}' : ''}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.phone,
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              doctor.phone,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (doctor.distance != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: AppSpacing.chipRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor.distance!.toStringAsFixed(1)} km',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.attach_money_rounded,
                              size: 12,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            doctor.consultationFee != null
                                ? '${doctor.consultationFee!.toStringAsFixed(0)} DA'
                                : 'Prix non spécifié',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: doctor.consultationFee != null
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (doctor.yearsOfExperience != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.work_outline_rounded,
                              size: 12,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${doctor.yearsOfExperience} ans',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildNextAvailableSlot(),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (doctor.whatsappNumber != null &&
                        doctor.whatsappNumber!.isNotEmpty)
                      Expanded(
                        child: _buildActionButton(
                          icon: AppIcons.chat,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: _openWhatsApp,
                        ),
                      ),
                    if (doctor.whatsappNumber != null &&
                        doctor.whatsappNumber!.isNotEmpty)
                      const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: _buildActionButton(
                        icon: AppIcons.calendar,
                        label: 'Prendre RDV',
                        color: AppColors.primary,
                        onTap: _bookAppointment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextAvailableSlot() {
    return FutureBuilder<String?>(
      future: _getNextAvailableSlot(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppSpacing.chipRadius,
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  'Prochain créneau: ${snapshot.data}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.successDark,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<String?> _getNextAvailableSlot() async {
    try {
      if (Get.isRegistered<AppointmentRepository>()) {
        final repo = Get.find<AppointmentRepository>();
        return await repo.getNextAvailableSlot(doctor.id);
      }
    } catch (_) {}
    return null;
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.buttonRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppSpacing.buttonRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bookAppointment() {
    Get.toNamed('/book-appointment', arguments: doctor);
  }

  void _openWhatsApp() async {
    if (doctor.whatsappNumber != null) {
      final url =
          'https://wa.me/${doctor.whatsappNumber!.replaceAll(RegExp(r'[^\d+]'), '')}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String _getInitials() {
    final parts = doctor.doctorName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return doctor.doctorName.substring(0, 1).toUpperCase();
  }

  String _formatDoctorName(String name) {
    if (name.startsWith('Dr') || name.startsWith('DR')) {
      return name;
    }
    return 'Dr. $name';
  }
}
