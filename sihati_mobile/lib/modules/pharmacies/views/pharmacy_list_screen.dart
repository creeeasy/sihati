import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_widget.dart';
import '../controllers/pharmacy_list_controller.dart';
import 'widgets/pharmacy_card.dart';

class PharmacyListScreen extends GetView<PharmacyListController> {
  const PharmacyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.showOnlyOpenPharmacies,
            icon: Icon(controller.showActiveOnly.value
                ? Icons.clear_all_rounded
                : Icons.storefront_rounded),
            label: Text(
                controller.showActiveOnly.value ? 'Afficher tout' : 'Ouvertes'),
            backgroundColor: controller.showActiveOnly.value
                ? AppColors.error
                : AppColors.success,
          )),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildActiveFilterBar()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _buildPharmacyList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient)),
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: CustomPaint(
                  size: Size(Get.width, 30), painter: WavePainter()),
            ),
            Positioned(
              top: 60,
              right: -20,
              child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1))),
            ),
            Positioned(
              top: 90,
              left: 30,
              child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08))),
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
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.store_rounded,
                              color: Colors.white, size: 28),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pharmacies',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2)),
                              SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.activePharmaciesCount,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500),
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
                offset: Offset(0, 4))
          ],
        ),
        child: TextField(
          onChanged: controller.searchPharmacies,
          onTap: () => controller.isSearchFocused.value = true,
          decoration: InputDecoration(
            hintText: 'Rechercher une pharmacie...',
            hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
            prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 22)),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: () => controller.searchPharmacies(''))
                : const SizedBox()),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ),
    );
  }

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
            SizedBox(width: 8),
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                    SizedBox(width: 4),
                    Text('Effacer',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Obx(() => _buildFilterChip(
                  label: 'Ouvertes',
                  icon: Icons.storefront_rounded,
                  isSelected: controller.showActiveOnly.value,
                  onTap: controller.toggleActiveFilter,
                  color: AppColors.success,
                )),
            SizedBox(width: AppSpacing.sm),
            Obx(() => _buildFilterChip(
                  label: 'À proximité',
                  icon: Icons.near_me_rounded,
                  isSelected: controller.showNearbyOnly.value,
                  onTap: controller.toggleNearbyFilter,
                  color: AppColors.primary,
                )),
            SizedBox(width: AppSpacing.sm),
            Obx(() => _buildFilterChip(
                  label: controller.selectedWilaya.value ?? 'Wilaya',
                  icon: Icons.location_on_rounded,
                  isSelected: controller.selectedWilaya.value != null,
                  onTap: _showWilayaDialog,
                  color: AppColors.secondary,
                )),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverFillRemaining(
            child: const LoadingIndicator(
                message: 'Chargement des pharmacies...'));
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
            child: ErrorDisplayWidget(
                message: controller.errorMessage.value,
                onRetry: controller.refresh));
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

      return SliverPadding(
        padding: EdgeInsets.all(AppSpacing.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final pharmacy = pharmacies[index];
              return PharmacyCard(
                  pharmacy: pharmacy,
                  onTap: () => controller.goToPharmacyDetail(pharmacy.id));
            },
            childCount: pharmacies.length,
          ),
        ),
      );
    });
  }

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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Text('Sélectionner une wilaya',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
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
                        controller.selectedWilaya.value == wilaya;
                    return InkWell(
                      onTap: () {
                        controller
                            .filterByWilaya(wilaya == 'Tous' ? null : wilaya);
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 4),
                        margin: EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
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

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFF9FAFB)
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
