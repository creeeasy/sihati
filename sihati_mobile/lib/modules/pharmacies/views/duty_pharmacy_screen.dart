import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/core/utils/villes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_widget.dart';
import '../controllers/duty_pharmacy_controller.dart';
import 'widgets/pharmacy_card.dart';

class DutyPharmacyScreen extends GetView<DutyPharmacyController> {
  const DutyPharmacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,

      // ── FABs ─────────────────────────────────────────────────
      floatingActionButton: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Clear all — only when filters are active
              if (controller.activeFiltersCount > 0) ...[
                _StyledMiniFab(
                  heroTag: 'clearDuty',
                  onPressed: controller.clearFilters,
                  icon: AppIcons.close,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Nearby toggle
              _StyledExtendedFab(
                heroTag: 'nearbyDuty',
                onPressed: controller.toggleNearbyFilter,
                icon: controller.showNearbyOnly.value
                    ? AppIcons.close
                    : AppIcons.location,
                label: controller.showNearbyOnly.value
                    ? 'Toutes les wilayas'
                    : 'À proximité',
                color: controller.showNearbyOnly.value
                    ? AppColors.error
                    : AppColors.primary,
              ),
            ],
          )),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildActiveFilterBar()),
          _buildPharmacyList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary800,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: _PressableWidget(
          onTap: () => Get.back(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: AppColors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.arrowBack,
                width: AppSpacing.iconSizeMd,
                height: AppSpacing.iconSizeMd,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Wilaya picker action
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: _PressableWidget(
            onTap: _showWilayaDialog,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.location,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                        controller.selectedWilaya.value ?? 'Wilaya',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                        ),
                      )),
                  // Dot indicator when filter is active
                  Obx(() {
                    if (controller.selectedWilaya.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Deep gradient — slightly warmer/darker to distinguish from
            // the standard pharmacy list screen
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary900,
                    AppColors.primary700,
                  ],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -24,
              right: -24,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 70,
              right: 70,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: -16,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Smooth wave
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 32),
                painter: _SmoothWavePainter(color: AppColors.neutral50),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pharmacy icon with night tint
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.moon,
                            width: AppSpacing.iconSizeLg,
                            height: AppSpacing.iconSizeLg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
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
                                'Pharmacies de garde',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.pharmacyCountLabel,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Date/time pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.reminder,
                            width: 13,
                            height: 13,
                            colorFilter: ColorFilter.mode(
                              AppColors.white.withOpacity(0.9),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            controller.currentDateTime,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIVE FILTER BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActiveFilterBar() {
    return Obx(() {
      final count = controller.activeFiltersCount;
      final wilaya = controller.selectedWilaya.value;

      if (count == 0) return const SizedBox(height: AppSpacing.xs);

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (controller.showNearbyOnly.value)
              _buildFilterBadge(
                label: 'À proximité',
                icon: AppIcons.location,
                color: AppColors.primary,
                onClear: controller.toggleNearbyFilter,
              ),
            if (wilaya != null)
              _buildFilterBadge(
                label: wilaya,
                icon: AppIcons.location,
                color: AppColors.secondary,
                onClear: () => controller.filterByWilaya(null),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterBadge({
    required String label,
    required String icon,
    required Color color,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: 13,
            height: 13,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          _PressableWidget(
            onTap: onClear,
            child: SvgPicture.asset(
              AppIcons.close,
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PHARMACY LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPharmacyList() {
    return Obx(() {
      // Loading
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: LoadingIndicator(
            message: 'Chargement des pharmacies de garde...',
          ),
        );
      }

      // Error
      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          ),
        );
      }

      final pharmacies = controller.pharmacies;

      // Empty
      if (pharmacies.isEmpty) {
        final isNearby = controller.showNearbyOnly.value;
        final hasWilaya = controller.selectedWilaya.value != null;

        return SliverFillRemaining(
          child: EmptyState(
            message: 'Aucune pharmacie de garde',
            submessage: isNearby
                ? "Aucune pharmacie de garde à proximité. Essayez d'élargir la zone."
                : hasWilaya
                    ? 'Aucune pharmacie de garde dans cette wilaya ce soir.'
                    : 'Aucune pharmacie de garde disponible pour le moment.',
            icon: AppIcons.pharmacy,
            onRetry: controller.activeFiltersCount > 0
                ? controller.clearFilters
                : controller.refresh,
            retryText: controller.activeFiltersCount > 0
                ? 'Réinitialiser les filtres'
                : 'Actualiser',
          ),
        );
      }

      // Results
      return SliverList(
        delegate: SliverChildListDelegate([
          // ── Success banner ──
          _buildSuccessBanner(pharmacies.length),
          const SizedBox(height: AppSpacing.xs),

          // ── Cards ──
          ...pharmacies.map((pharmacy) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: PharmacyCard(
                  pharmacy: pharmacy,
                  onTap: () => controller.goToPharmacyDetail(pharmacy.id),
                ),
              )),

          // FAB clearance
          const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),
        ]),
      );
    });
  }

  Widget _buildSuccessBanner(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success50,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.success.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SvgPicture.asset(
              AppIcons.moon,
              width: AppSpacing.iconSizeMd,
              height: AppSpacing.iconSizeMd,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
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
                  '$count pharmacie${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.success700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.showNearbyOnly.value
                      ? 'Les plus proches de vous cette nuit'
                      : 'Ouvertes cette nuit dans votre région',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success700.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WILAYA DIALOG
  // ═══════════════════════════════════════════════════════════════

  void _showWilayaDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor: AppColors.surfaceCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          constraints: BoxConstraints(maxHeight: Get.height * 0.68),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.location,
                      width: AppSpacing.iconSizeMd,
                      height: AppSpacing.iconSizeMd,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Sélectionner une wilaya',
                    style: AppTextStyles.h5,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.borderDefault, height: 1),
              const SizedBox(height: AppSpacing.xs),

              // List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: algerianWilayas.length,
                  itemBuilder: (context, index) {
                    final wilaya = algerianWilayas[index];
                    final isSelected =
                        controller.selectedWilaya.value == wilaya ||
                            (wilaya == 'Tous' &&
                                controller.selectedWilaya.value == null);

                    return _PressableWidget(
                      onTap: () {
                        controller
                            .filterByWilaya(wilaya == 'Tous' ? null : wilaya);
                        Get.back();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySoft
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Custom radio circle
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.neutral300,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? SvgPicture.asset(
                                      AppIcons.verified,
                                      width: 12,
                                      height: 12,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                wilaya,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STYLED FABs
// ═══════════════════════════════════════════════════════════════

class _StyledMiniFab extends StatelessWidget {
  final String heroTag;
  final VoidCallback onPressed;
  final String icon;
  final Color color;

  const _StyledMiniFab({
    required this.heroTag,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      onPressed: onPressed,
      backgroundColor: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: SvgPicture.asset(
        icon,
        width: AppSpacing.iconSizeSm,
        height: AppSpacing.iconSizeSm,
        colorFilter: const ColorFilter.mode(
          AppColors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _StyledExtendedFab extends StatelessWidget {
  final String heroTag;
  final VoidCallback onPressed;
  final String icon;
  final String label;
  final Color color;

  const _StyledExtendedFab({
    required this.heroTag,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      icon: SvgPicture.asset(
        icon,
        width: AppSpacing.iconSizeSm,
        height: AppSpacing.iconSizeSm,
        colorFilter: const ColorFilter.mode(
          AppColors.white,
          BlendMode.srcIn,
        ),
      ),
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRESS ANIMATION WRAPPER
// ═══════════════════════════════════════════════════════════════

class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableWidget({required this.child, this.onTap});

  @override
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WAVE PAINTER
// ═══════════════════════════════════════════════════════════════

class _SmoothWavePainter extends CustomPainter {
  final Color color;
  const _SmoothWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.0,
        size.width * 0.4,
        size.height * 0.0,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.6,
        size.height * 1.0,
        size.width * 0.8,
        size.height * 1.0,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmoothWavePainter old) => old.color != color;
}
