import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
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
      backgroundColor: AppColors.background,

      // ── FABs: nearby toggle + clear all ──────────────────────
      floatingActionButton: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Clear all filters — only shown when filters are active
              if (controller.activeFiltersCount > 0) ...[
                FloatingActionButton.small(
                  heroTag: 'clearDuty',
                  onPressed: controller.clearFilters,
                  backgroundColor: AppColors.error,
                  child: const Icon(Icons.filter_alt_off_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
              ],

              // Nearby toggle
              FloatingActionButton.extended(
                heroTag: 'nearbyDuty',
                onPressed: controller.toggleNearbyFilter,
                icon: Icon(
                  controller.showNearbyOnly.value
                      ? Icons.location_off_rounded
                      : Icons.near_me_rounded,
                ),
                label: Text(controller.showNearbyOnly.value
                    ? 'Toutes les wilayas'
                    : 'À proximité'),
                backgroundColor: controller.showNearbyOnly.value
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
  // HEADER — gradient with wave, reactive count, wilaya button
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      // Wilaya picker in action bar — now opens a proper bottom dialog
      // (consistent with PharmacyListScreen's _showWilayaDialog)
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white),
                Obx(() {
                  if (controller.selectedWilaya.value == null) {
                    return const SizedBox();
                  }
                  return Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            ),
            tooltip: 'Filtrer par wilaya',
            onPressed: _showWilayaDialog,
          ),
        ),
      ],
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
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.local_pharmacy_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pharmacies de garde',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Reactive count — like PharmacyListScreen
                              Obx(() => Text(
                                    controller.pharmacyCountLabel,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.currentDateTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
  // ACTIVE FILTER BAR — mirrors PharmacyListScreen style
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActiveFilterBar() {
    return Obx(() {
      final count = controller.activeFiltersCount;
      final wilaya = controller.selectedWilaya.value;

      if (count == 0) return const SizedBox(height: 8);

      return Container(
        margin: EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (controller.showNearbyOnly.value)
              _buildFilterChipBadge(
                label: 'À proximité',
                icon: Icons.near_me_rounded,
                color: AppColors.primary,
                onClear: controller.toggleNearbyFilter,
              ),
            if (wilaya != null)
              _buildFilterChipBadge(
                label: wilaya,
                icon: Icons.location_on_rounded,
                color: AppColors.secondary,
                onClear: () => controller.filterByWilaya(null),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChipBadge({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PHARMACY LIST — fixed: empty vs error are separate states
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPharmacyList() {
    return Obx(() {
      // Loading
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: LoadingIndicator(
              message: 'Chargement des pharmacies de garde...'),
        );
      }

      // Error (network / permission — not "empty result")
      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          ),
        );
      }

      final pharmacies = controller.pharmacies;

      // Empty result — FIX: previously shown as ErrorDisplayWidget
      // because the controller set errorMessage on empty. Now properly
      // separated: empty list → EmptyState, real error → ErrorDisplayWidget.
      if (pharmacies.isEmpty) {
        final isNearby = controller.showNearbyOnly.value;
        final hasWilaya = controller.selectedWilaya.value != null;

        return SliverFillRemaining(
          child: EmptyState(
            message: 'Aucune pharmacie de garde',
            submessage: isNearby
                ? 'Aucune pharmacie de garde à proximité. Essayez d\'élargir la zone.'
                : hasWilaya
                    ? 'Aucune pharmacie de garde dans cette wilaya ce soir.'
                    : 'Aucune pharmacie de garde disponible pour le moment.',
            icon: Icons.local_pharmacy_rounded,
            onRetry: controller.activeFiltersCount > 0
                ? controller.clearFilters
                : controller.refresh,
            retryText: controller.activeFiltersCount > 0
                ? 'Réinitialiser les filtres'
                : 'Actualiser',
          ),
        );
      }

      return SliverList(
        delegate: SliverChildListDelegate([
          // ── Success banner ──
          Container(
            margin: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.nightlight_round,
                      color: Colors.white, size: 22),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pharmacies.length} pharmacie${pharmacies.length > 1 ? 's' : ''} disponible${pharmacies.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successDark,
                        ),
                      ),
                      Text(
                        controller.showNearbyOnly.value
                            ? 'Les plus proches de vous cette nuit'
                            : 'Ouvertes cette nuit dans votre région',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.successDark.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Pharmacy cards ──
          ...pharmacies.map((pharmacy) => Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: PharmacyCard(
                  pharmacy: pharmacy,
                  onTap: () => controller.goToPharmacyDetail(pharmacy.id),
                ),
              )),

          // Bottom padding so FAB doesn't overlap last card
          SizedBox(height: AppSpacing.lg * 4),
        ]),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // WILAYA DIALOG — same pattern as PharmacyListScreen for consistency
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
                child: ListView.builder(
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
                        controller
                            .filterByWilaya(wilaya == 'Tous' ? null : wilaya);
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
// WAVE PAINTER — private to avoid conflict with PharmacyListScreen
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
