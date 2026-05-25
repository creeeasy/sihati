import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class PharmacyCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onTap;

  const PharmacyCard({
    Key? key,
    required this.pharmacy,
    required this.onTap,
  }) : super(key: key);

  Future<void> _callPharmacy(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: pharmacy.phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'appeler ce numéro')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'appel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpenNow = pharmacy.isOpenNow;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpenNow
              ? AppColors.success
              : (pharmacy.isOnDutyTonight
                  ? AppColors.primary
                  : AppColors.border),
          width: (isOpenNow || pharmacy.isOnDutyTonight) ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isOpenNow
                ? AppColors.success.withOpacity(0.15)
                : (pharmacy.isOnDutyTonight
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: icon + name/status + favorite ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isOpenNow
                            ? AppColors.success
                            : (pharmacy.isOnDutyTonight
                                ? AppColors.primary
                                : AppColors.primarySoft),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.pharmacy,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          (isOpenNow || pharmacy.isOnDutyTonight)
                              ? Colors.white
                              : AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pharmacy.pharmacyName,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Open/Closed badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: pharmacy.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        pharmacy.statusColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(pharmacy.statusIcon,
                                        size: 12, color: pharmacy.statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      pharmacy.statusText,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: pharmacy.statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // De garde badge
                              if (pharmacy.isOnDutyTonight && !isOpenNow) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.moon,
                                        width: 10,
                                        height: 10,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'GARDE',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Today's hours ──
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.history,
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textTertiary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pharmacy.todayHours,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Address ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.location,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.error,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        pharmacy.fullAddress,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Distance badge (if available) ──
                if (pharmacy.distance != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 4,
                        vertical: AppSpacing.sm - 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppIcons.directions,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pharmacy.formattedDistance,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // ── Bottom action row: phone + call button + WhatsApp ──
                Row(
                  children: [
                    // Phone number
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              AppIcons.phone,
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                AppColors.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              pharmacy.phone,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── CALL button (new) ──
                    GestureDetector(
                      onTap: () => _callPharmacy(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.phone,
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Appeler',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // WhatsApp badge
                    if (pharmacy.hasWhatsapp) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppIcons.chat,
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'WA',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
