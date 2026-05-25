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
import '../../../core/widgets/sihati_mapbox.dart';
import '../controllers/pharmacy_list_controller.dart';
import 'widgets/pharmacy_card.dart';

class PharmacyListScreen extends GetView<PharmacyListController> {
  const PharmacyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,

      // ── FABs ────────────────────────────────────────────────
      floatingActionButton: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Map / List toggle — mini FAB
              _StyledMiniFab(
                heroTag: 'mapToggle',
                onPressed: controller.toggleMapView,
                icon: controller.showMapView.value
                    ? AppIcons.menu
                    : AppIcons.location,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Open-only toggle — extended FAB
              _StyledExtendedFab(
                heroTag: 'openToggle',
                onPressed: controller.toggleActiveFilter,
                icon: controller.showActiveOnly.value
                    ? AppIcons.close
                    : AppIcons.pharmacy,
                label: controller.showActiveOnly.value
                    ? 'Afficher tout'
                    : 'Ouvertes',
                color: controller.showActiveOnly.value
                    ? AppColors.error
                    : AppColors.success,
              ),
            ],
          )),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildActiveFilterBar()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _buildBody(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 156,
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
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.homeHeaderGradient,
              ),
            ),

            // Decorative circles
            Positioned(
              top: -24,
              right: -24,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: 60,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Smooth wave at bottom
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 32),
                painter: _SmoothWavePainter(color: AppColors.neutral50),
              ),
            ),

            // Header content
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
                        // Icon block
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.pharmacy,
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
                                'Pharmacies',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.activePharmaciesCount,
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
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppColors.shadowMd,
        ),
        child: TextField(
          onChanged: controller.searchPharmacies,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher une pharmacie...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SvgPicture.asset(
                AppIcons.search,
                width: AppSpacing.iconSizeMd,
                height: AppSpacing.iconSizeMd,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: Obx(() {
              if (controller.isSearchLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              if (controller.searchQuery.value.isNotEmpty) {
                return IconButton(
                  icon: SvgPicture.asset(
                    AppIcons.close,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => controller.searchPharmacies(''),
                );
              }
              return const SizedBox.shrink();
            }),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIVE FILTER BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActiveFilterBar() {
    return Obx(() {
      if (controller.activeFiltersCount == 0) return const SizedBox();

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              AppIcons.filter,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                '${controller.activeFiltersCount} filtre${controller.activeFiltersCount > 1 ? 's' : ''} actif${controller.activeFiltersCount > 1 ? 's' : ''}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            _PressableWidget(
              onTap: controller.clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.close,
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.error,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Effacer',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        physics: const BouncingScrollPhysics(),
        children: [
          // Ouvertes
          Obx(() => _buildFilterChip(
                label: 'Ouvertes',
                icon: AppIcons.pharmacy,
                isSelected: controller.showActiveOnly.value,
                onTap: controller.toggleActiveFilter,
                color: AppColors.success,
              )),
          const SizedBox(width: AppSpacing.xs),

          // À proximité
          Obx(() => _buildFilterChip(
                label: 'À proximité',
                icon: AppIcons.location,
                isSelected: controller.showNearbyOnly.value,
                onTap: controller.toggleNearbyFilter,
                color: AppColors.primary,
              )),
          const SizedBox(width: AppSpacing.xs),

          // Wilaya
          Obx(() => _buildFilterChip(
                label: controller.selectedWilaya.value ?? 'Wilaya',
                icon: AppIcons.location,
                isSelected: controller.selectedWilaya.value != null,
                onTap: _showWilayaDialog,
                color: AppColors.secondary,
              )),
          const SizedBox(width: AppSpacing.xs),

          // De garde — nav chip (amber)
          _buildFilterChip(
            label: 'De garde',
            icon: AppIcons.moon,
            isSelected: false,
            onTap: controller.goToDutyPharmacies,
            color: AppColors.warning,
            isNavChip: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    bool isNavChip = false,
  }) {
    return _PressableWidget(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : isNavChip
                  ? color.withOpacity(0.1)
                  : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color:
                isSelected ? color : color.withOpacity(isNavChip ? 0.5 : 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : AppColors.shadowXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.white : color,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSpacing.xs - 2),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            if (isNavChip) ...[
              const SizedBox(width: 4),
              SvgPicture.asset(
                AppIcons.arrowForward,
                width: 10,
                height: 10,
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: LoadingIndicator(message: 'Chargement des pharmacies...'),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          ),
        );
      }

      final pharmacies = controller.filteredPharmacies;

      if (pharmacies.isEmpty) {
        String message = 'Aucune pharmacie trouvée';
        String submessage = 'Essayez de modifier vos filtres';

        if (controller.showActiveOnly.value) {
          message = 'Aucune pharmacie ouverte';
          submessage = 'Toutes les pharmacies sont fermées pour le moment';
        } else if (controller.showNearbyOnly.value) {
          message = 'Aucune pharmacie à proximité';
          submessage = "Essayez d'élargir votre recherche";
        } else if (controller.searchQuery.value.isNotEmpty) {
          message = 'Aucun résultat';
          submessage =
              'Aucune pharmacie ne correspond à "${controller.searchQuery.value}"';
        }

        return SliverFillRemaining(
          child: EmptyState(
            message: message,
            submessage: submessage,
            icon: AppIcons.pharmacy,
            onRetry: controller.clearFilters,
            retryText: 'Réinitialiser',
          ),
        );
      }

      if (controller.showMapView.value) {
        return SliverFillRemaining(child: _buildMapView(pharmacies));
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final pharmacy = pharmacies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: PharmacyCard(
                  pharmacy: pharmacy,
                  onTap: () => controller.goToPharmacyDetail(pharmacy.id),
                ),
              );
            },
            childCount: pharmacies.length,
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // MAP VIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMapView(List pharmacies) {
    return Obx(() {
      final idx = controller.centredIndex.value.clamp(0, pharmacies.length - 1);
      final centred = pharmacies[idx];

      return Stack(
        children: [
          // Full-screen map
          SihatiMapbox(
            latitude: centred.latitude,
            longitude: centred.longitude,
            markerTitle: centred.pharmacyName,
            height: double.infinity,
            zoom: 13,
          ),

          // Count pill at top
          Positioned(
            top: AppSpacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: AppColors.shadowMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.pharmacy,
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${pharmacies.length} pharmacie${pharmacies.length > 1 ? 's' : ''}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Horizontal card strip
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 168,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacies[index];
                  final isSelected = controller.centredIndex.value == index;

                  return _PressableWidget(
                    onTap: () =>
                        controller.selectMapPharmacy(index, pharmacy.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: 264,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppSpacing.cardRadius,
                        // Left-border accent pattern (status-coded)
                        border: Border(
                          left: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : pharmacy.isOpenNow
                                    ? AppColors.success
                                    : AppColors.neutral300,
                            width: 4,
                          ),
                          top: BorderSide(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.borderLight,
                            width: 1,
                          ),
                          right: BorderSide(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.borderLight,
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        boxShadow: isSelected
                            ? AppColors.shadowPrimary
                            : AppColors.shadowMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name + status badge
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(AppSpacing.xs - 2),
                                decoration: BoxDecoration(
                                  color: pharmacy.isOpenNow
                                      ? AppColors.success50
                                      : AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm),
                                ),
                                child: SvgPicture.asset(
                                  AppIcons.pharmacy,
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    pharmacy.isOpenNow
                                        ? AppColors.success
                                        : AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  pharmacy.pharmacyName,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: pharmacy.statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull),
                                ),
                                child: Text(
                                  pharmacy.statusText,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: pharmacy.statusColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xs),
                          Divider(
                            color: AppColors.neutral100,
                            height: 1,
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          // Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AppIcons.location,
                                width: 12,
                                height: 12,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.error,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pharmacy.fullAddress,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xs - 2),

                          // Hours + distance
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.reminder,
                                width: 12,
                                height: 12,
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
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              if (pharmacy.distance != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    pharmacy.formattedDistance,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
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
              Divider(color: AppColors.borderDefault, height: 1),
              const SizedBox(height: AppSpacing.xs),

              // Wilaya list
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

  const _StyledMiniFab({
    required this.heroTag,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
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
