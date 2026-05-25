import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/sihati_mapbox.dart';
import '../controllers/doctor_detail_controller.dart';

class DoctorDetailScreen extends GetView<DoctorDetailController> {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      bottomNavigationBar: Obx(() {
        if (controller.doctor.value != null && !controller.isLoading.value) {
          return _buildBottomBar();
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, MediaQuery.of(Get.context!).padding.bottom + AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        boxShadow: AppColors.shadowMd,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: InkWell(
        onTap: controller.bookAppointment,
        borderRadius: AppSpacing.buttonRadius,
        child: Container(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppSpacing.buttonRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.calendar,
                width: AppSpacing.iconSizeMd,
                height: AppSpacing.iconSizeMd,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Prendre rendez-vous',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
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
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
                child: SihatiMapbox(
                  latitude: doctor.latitude,
                  longitude: doctor.longitude,
                  markerTitle: doctor.clinicName,
                  height: double.infinity,
                  zoom: 15,
                ),
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
                icon: controller.isFavorite.value ? AppIcons.favoriteFilled : AppIcons.favoriteOutlined,
                onPressed: controller.toggleFavorite,
                color: controller.isFavorite.value ? AppColors.error : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: AppIcons.share,
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
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        boxShadow: AppColors.shadowSm,
      ),
      child: IconButton(
        icon: SvgPicture.asset(AppIcons.arrowBack, width: AppSpacing.iconSizeMd, height: AppSpacing.iconSizeMd, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        boxShadow: AppColors.shadowSm,
      ),
      child: IconButton(
        icon: SvgPicture.asset(icon, width: AppSpacing.iconSizeMd, height: AppSpacing.iconSizeMd, colorFilter: ColorFilter.mode(color ?? AppColors.textPrimary, BlendMode.srcIn)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDetailsSheet(doctor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        boxShadow: AppColors.shadowMd,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                CircleAvatar(
                  radius: AppSpacing.avatarSizeLg / 2,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    _getInitials(doctor.doctorName),
                    style: AppTextStyles.headline.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDoctorName(doctor.doctorName),
                        style: AppTextStyles.headline,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: AppSpacing.chipRadius,
                        ),
                        child: Text(
                          doctor.specialty?.nameFr ?? 'Spécialiste',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (doctor.averageRating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(AppIcons.starFilled, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.warning, BlendMode.srcIn)),
                            const SizedBox(width: 4),
                            Text(
                              doctor.averageRating!.toStringAsFixed(1),
                              style: AppTextStyles.title.copyWith(color: AppColors.warning700),
                            ),
                          ],
                        ),
                        if (doctor.totalReviews != null)
                          Text(
                            '${doctor.totalReviews}',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning700),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: controller.callDoctor,
                    borderRadius: AppSpacing.buttonRadius,
                    child: Container(
                      height: AppSpacing.buttonHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppSpacing.buttonRadius,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppIcons.phone, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                          const SizedBox(width: 8),
                          Text('Appeler', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (doctor.whatsappNumber != null && doctor.whatsappNumber!.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: InkWell(
                      onTap: controller.openWhatsApp,
                      borderRadius: AppSpacing.buttonRadius,
                      child: Container(
                        height: AppSpacing.buttonHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.1),
                          borderRadius: AppSpacing.buttonRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppIcons.chat, width: 20, height: 20, colorFilter: const ColorFilter.mode(Color(0xFF25D366), BlendMode.srcIn)),
                            const SizedBox(width: 8),
                            Text('WhatsApp', style: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF25D366))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Obx(() {
              if (controller.nextAvailableSlot.value != null) {
                return _buildNextSlotCard(controller.nextAvailableSlot.value!);
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: AppIcons.doctor,
                    label: 'Consultation',
                    value: controller.formattedFee,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: AppIcons.hospital,
                    label: 'Expérience',
                    value: doctor.yearsOfExperience != null ? '${doctor.yearsOfExperience} ans' : 'N/A',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: AppIcons.location,
                    label: 'Distance',
                    value: doctor.distance != null ? '${doctor.distance!.toStringAsFixed(1)} km' : 'N/A',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildQuickInfoCard(
                    icon: AppIcons.location,
                    label: 'Wilaya',
                    value: doctor.wilaya,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const Divider(color: AppColors.borderDefault),
              const SizedBox(height: AppSpacing.md),
              _buildSectionTitle('À propos'),
              const SizedBox(height: AppSpacing.sm),
              Text(
                doctor.bio!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.borderDefault),
            const SizedBox(height: AppSpacing.md),
            _buildSectionTitle('Cabinet médical'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.paddingCard,
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (doctor.clinicName.isNotEmpty) ...[
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.hospital, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(doctor.clinicName, style: AppTextStyles.title),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(AppIcons.location, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          controller.fullAddress,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: controller.getDirections,
                    borderRadius: AppSpacing.buttonRadius,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: AppSpacing.buttonRadius,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppIcons.directions, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                          const SizedBox(width: 8),
                          Text('Obtenir l\'itinéraire', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.borderDefault),
            const SizedBox(height: AppSpacing.md),
            _buildSectionTitle('Horaires de travail'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.paddingCard,
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'Voir les créneaux disponibles en réservant un rendez-vous',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSlotCard(String slot) {
    return InkWell(
      onTap: controller.bookAppointment,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: AppSpacing.paddingCard,
        decoration: BoxDecoration(
          color: AppColors.success50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.success200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: SvgPicture.asset(AppIcons.appointment, width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prochain créneau disponible',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.success700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot,
                    style: AppTextStyles.title.copyWith(color: AppColors.success700),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(AppIcons.arrowForward, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.success700, BlendMode.srcIn)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(icon, width: 22, height: 22, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(color: color),
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
        Text(title, style: AppTextStyles.headline),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  String _formatDoctorName(String name) {
    if (name.startsWith('Dr') || name.startsWith('DR')) {
      return name;
    }
    return 'Dr. $name';
  }
}
