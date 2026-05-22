import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
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
      backgroundColor: AppColors.background,

      // ── FABs ─────────────────────────────────────────────────
      floatingActionButton: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Map / List toggle
              FloatingActionButton(
                heroTag: 'mapToggle',
                mini: true,
                onPressed: controller.toggleMapView,
                backgroundColor: AppColors.primary,
                child: Icon(
                  controller.showMapView.value
                      ? Icons.list_rounded
                      : Icons.map_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Open-only toggle
              // FIX: now calls toggleActiveFilter() directly so toggling OFF
              // does NOT wipe wilaya / nearby / search (old bug via clearFilters).
              FloatingActionButton.extended(
                heroTag: 'openToggle',
                onPressed: controller.toggleActiveFilter,
                icon: Icon(
                  controller.showActiveOnly.value
                      ? Icons.clear_all_rounded
                      : Icons.storefront_rounded,
                ),
                label: Text(
                  controller.showActiveOnly.value
                      ? 'Afficher tout'
                      : 'Ouvertes',
                ),
                backgroundColor: controller.showActiveOnly.value
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
          submessage = 'Essayez d\'élargir votre recherche';
        } else if (controller.searchQuery.value.isNotEmpty) {
          message = 'Aucun résultat';
          submessage =
              'Aucune pharmacie ne correspond à "${controller.searchQuery.value}"';
        }

        return SliverFillRemaining(
          child: EmptyState(
            message: message,
            submessage: submessage,
            icon: controller.showActiveOnly.value
                ? Icons.storefront_rounded
                : Icons.store_rounded,
            onRetry: controller.clearFilters,
            retryText: 'Réinitialiser',
          ),
        );
      }

      if (controller.showMapView.value) {
        return SliverFillRemaining(child: _buildMapView(pharmacies));
      }

      return SliverPadding(
        padding: EdgeInsets.all(AppSpacing.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final pharmacy = pharmacies[index];
              return PharmacyCard(
                pharmacy: pharmacy,
                onTap: () => controller.goToPharmacyDetail(pharmacy.id),
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
      final idx =
          controller.centredIndex.value.clamp(0, pharmacies.length - 1) as int;
      final centred = pharmacies[idx];

      return Stack(
        children: [
          // Map centred on selected pharmacy
          SihatiMapbox(
            latitude: centred.latitude,
            longitude: centred.longitude,
            markerTitle: centred.pharmacyName,
            height: double.infinity,
            zoom: 13,
          ),

          // Pharmacy count pill
          Positioned(
            top: AppSpacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_pharmacy_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${pharmacies.length} pharmacie${pharmacies.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Horizontal card strip — tap re-centres map + navigates to detail
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                physics: const BouncingScrollPhysics(),
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = pharmacies[index];
                  final isSelected = controller.centredIndex.value == index;

                  return GestureDetector(
                    onTap: () =>
                        controller.selectMapPharmacy(index, pharmacy.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 260,
                      margin: EdgeInsets.only(right: AppSpacing.sm),
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : pharmacy.isOpenNow
                                  ? AppColors.success
                                  : AppColors.border,
                          width: (isSelected ||
                                  pharmacy.isOpenNow ||
                                  pharmacy.isOnDutyTonight)
                              ? 2
                              : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isSelected ? 0.18 : 0.10),
                            blurRadius: isSelected ? 20 : 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name + status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: pharmacy.isOpenNow
                                      ? AppColors.success
                                      : AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.local_pharmacy_rounded,
                                  size: 18,
                                  color: pharmacy.isOpenNow
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pharmacy.pharmacyName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: pharmacy.statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pharmacy.statusText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: pharmacy.statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Address
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 12, color: AppColors.error),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pharmacy.fullAddress,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Hours + distance
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 12, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pharmacy.todayHours,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (pharmacy.distance != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pharmacy.formattedDistance,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
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
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 30),
                painter: _WavePainter(),
              ),
            ),
            Positioned(
              top: 60,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 90,
              left: 30,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.store_rounded,
                              color: Colors.white, size: 28),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pharmacies',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.activePharmaciesCount,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
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
  // SEARCH BAR — with backend search spinner
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.searchPharmacies,
          decoration: InputDecoration(
            hintText: 'Rechercher une pharmacie...',
            hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.search_rounded,
                  color: AppColors.primary, size: 22),
            ),
            // FIX: suffix shows a spinner during backend search,
            // a clear button when there is a query, or nothing otherwise.
            suffixIcon: Obx(() {
              if (controller.isSearchLoading.value) {
                return Padding(
                  padding: const EdgeInsets.all(14),
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
                  icon: Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: () => controller.searchPharmacies(''),
                );
              }
              return const SizedBox.shrink();
            }),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
        margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${controller.activeFiltersCount} filtre${controller.activeFiltersCount > 1 ? 's' : ''} actif${controller.activeFiltersCount > 1 ? 's' : ''}',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap: controller.clearFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Effacer',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error),
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
  // FILTER CHIPS — added "De garde" navigation chip
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Ouvertes
            Obx(() => _buildFilterChip(
                  label: 'Ouvertes',
                  icon: Icons.storefront_rounded,
                  isSelected: controller.showActiveOnly.value,
                  onTap: controller.toggleActiveFilter,
                  color: AppColors.success,
                )),
            SizedBox(width: AppSpacing.sm),

            // À proximité
            Obx(() => _buildFilterChip(
                  label: 'À proximité',
                  icon: Icons.near_me_rounded,
                  isSelected: controller.showNearbyOnly.value,
                  onTap: controller.toggleNearbyFilter,
                  color: AppColors.primary,
                )),
            SizedBox(width: AppSpacing.sm),

            // Wilaya
            Obx(() => _buildFilterChip(
                  label: controller.selectedWilaya.value ?? 'Wilaya',
                  icon: Icons.location_on_rounded,
                  isSelected: controller.selectedWilaya.value != null,
                  onTap: _showWilayaDialog,
                  color: AppColors.secondary,
                )),
            SizedBox(width: AppSpacing.sm),

            // De garde — navigation shortcut to the duty screen.
            // Styled as an amber accent chip to distinguish it from
            // filter chips (it navigates instead of filtering).
            _buildFilterChip(
              label: 'De garde',
              icon: Icons.nightlight_round,
              isSelected: false,
              onTap: controller.goToDutyPharmacies,
              color: const Color(0xFFE9960A), // amber / night tone
              isNavChip: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    bool isNavChip = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : isNavChip
                  ? color.withOpacity(0.10)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.4),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : isNavChip
                        ? color
                        : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : isNavChip
                        ? color
                        : AppColors.textPrimary,
              ),
            ),
            // Arrow hint for nav chip
            if (isNavChip) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 11, color: color),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WILAYA DIALOG
  // ═══════════════════════════════════════════════════════════════

  void _showWilayaDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          constraints: BoxConstraints(maxHeight: Get.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  SizedBox(width: AppSpacing.md),
                  const Text(
                    'Sélectionner une wilaya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Divider(color: AppColors.border),
              Flexible(
                child: Obx(() => ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.wilayas.length,
                      itemBuilder: (context, index) {
                        final wilaya = controller.wilayas[index];
                        final isSelected =
                            controller.selectedWilaya.value == wilaya ||
                                (wilaya == 'Tous' &&
                                    controller.selectedWilaya.value == null);
                        return InkWell(
                          onTap: () {
                            controller.filterByWilaya(
                                wilaya == 'Tous' ? null : wilaya);
                            Get.back();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primarySoft
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    wilaya,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_rounded,
                                      size: 18, color: AppColors.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WAVE PAINTER — private, no conflict with other screens
// ═══════════════════════════════════════════════════════════════

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF9FAFB)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2,
          size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.8, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
