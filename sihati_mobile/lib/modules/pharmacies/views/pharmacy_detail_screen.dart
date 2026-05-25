import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/sihati_mapbox.dart';
import '../controllers/pharmacy_detail_controller.dart';

class PharmacyDetailScreen extends GetView<PharmacyDetailController> {
  const PharmacyDetailScreen({Key? key}) : super(key: key);

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
            onRetry: controller.loadPharmacyDetails,
          );
        }

        final pharmacy = controller.pharmacy.value;
        if (pharmacy == null) {
          return const ErrorDisplayWidget(message: 'Pharmacie non trouvée');
        }

        final topPadding = MediaQuery.of(context).padding.top + 8;

        return Stack(
          children: [
            // ── Map (top half) + Details sheet (bottom half) ──
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: SihatiMapbox(
                    latitude: pharmacy.latitude,
                    longitude: pharmacy.longitude,
                    markerTitle: pharmacy.pharmacyName,
                    height: double.infinity,
                    zoom: 15,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: _buildDetailsSheet(pharmacy),
                ),
              ],
            ),

            // ── Back button — always top-left ──
            Positioned(
              top: topPadding,
              left: 8,
              child: _buildBackButton(),
            ),

            // ── De Garde badge — top-right, shifted left when present ──
            if (pharmacy.isOnDutyTonight)
              Positioned(
                top: topPadding,
                right: 56, // leave room for favorite button
                child: _buildOnDutyBadge(),
              ),

            // ── Favorite button — always top-right:8 ──
            Positioned(
              top: topPadding,
              right: 8,
              child: _buildFloatingFavorite(pharmacy),
            ),
          ],
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OVERLAY BUTTONS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFloatingFavorite(pharmacy) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final isFav = controller.isFavorite.value;
        final color = isFav ? AppColors.error : AppColors.textSecondary;
        return IconButton(
          icon: SvgPicture.asset(
            isFav ? AppIcons.favoriteFilled : AppIcons.favoriteOutlined,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          onPressed: controller.toggleFavorite,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          AppIcons.arrowBack,
          width: AppSpacing.iconSizeMd,
          height: AppSpacing.iconSizeMd,
          colorFilter:
              const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildOnDutyBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.moon,
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Text(
            'DE GARDE',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DETAILS SHEET
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDetailsSheet(pharmacy) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Name + address header ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: pharmacy.isOnDutyTonight
                        ? AppColors.primary
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.pharmacy,
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      pharmacy.isOnDutyTonight
                          ? Colors.white
                          : AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.pharmacyName,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildInfoChip(
                        icon: AppIcons.location,
                        text: pharmacy.fullAddress,
                        iconColor: AppColors.error,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Distance badge ──
            if (pharmacy.distance != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.directions,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                          AppColors.primary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'À ${pharmacy.formattedDistance}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // ── Action buttons ──
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: AppIcons.phone,
                    label: 'Appeler',
                    color: AppColors.primary,
                    onPressed: controller.callPharmacy,
                  ),
                ),
                if (pharmacy.hasWhatsapp) ...[
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: _buildActionButton(
                      icon: AppIcons.chat,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onPressed: controller.openWhatsApp,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.sm + 4),

            _buildActionButton(
              icon: AppIcons.directions,
              label: 'Obtenir l\'itinéraire',
              color: AppColors.primary,
              isOutlined: true,
              onPressed: controller.getDirections,
            ),

            // ── Opening hours ──
            if (controller.openingHoursList.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildSectionCard(
                icon: AppIcons.history,
                title: 'Horaires d\'ouverture',
                iconColor: AppColors.primary,
                child: _buildOpeningHoursTable(),
              ),
            ],

            // ── Contact ──
            const SizedBox(height: AppSpacing.md),
            _buildSectionCard(
              icon: AppIcons.phone,
              title: 'Contact',
              iconColor: AppColors.primary,
              child: Column(
                children: [
                  _buildContactRow(
                    icon: AppIcons.phone,
                    label: 'Téléphone',
                    value: pharmacy.phone,
                    color: AppColors.primary,
                  ),
                  if (pharmacy.hasWhatsapp) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildContactRow(
                      icon: AppIcons.chat,
                      label: 'WhatsApp',
                      value: pharmacy.whatsappNumber!,
                      color: const Color(0xFF25D366),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OPENING HOURS TABLE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildOpeningHoursTable() {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0 = Monday
    final frenchDays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    final todayLabel = frenchDays[todayIndex];

    return Column(
      children: controller.openingHoursList.map((entry) {
        final isClosed = entry.value == 'Fermé';
        final isToday = entry.key == todayLabel;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(color: AppColors.primary.withOpacity(0.2))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isToday)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    entry.key,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isClosed ? AppColors.errorLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.value,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isClosed ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoChip({
    required String icon,
    required String text,
    required Color iconColor,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: SvgPicture.asset(
            icon,
            width: 14,
            height: 14,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOutlined ? color : Colors.transparent,
              width: 2,
            ),
            boxShadow: isOutlined
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                    isOutlined ? color : Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String icon,
    required String title,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Text(
                title,
                style: AppTextStyles.displayMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
