import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import '../controllers/doctor_list_controller.dart';
import 'widgets/doctor_card.dart';

class DoctorListScreen extends GetView<DoctorListController> {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildEpicHeader(),
          SliverToBoxAdapter(child: _buildSearchSection()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _buildDoctorsList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EPIC WAVE HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEpicHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: _showEpicFilterBottomSheet,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Primary gradient
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),

            // Wave decoration
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 40),
                painter: WavePainter(),
              ),
            ),

            // Decorative circles
            Positioned(
              top: 60,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: 80,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl + 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md + 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Médecins',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 6),
                              Obx(() => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.health_and_safety_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${controller.filteredDoctors.length} médecin${controller.filteredDoctors.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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
  // SEARCH SECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un médecin...',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md + 2,
                  ),
                ),
                onChanged: controller.searchDoctorsByName,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showEpicFilterBottomSheet,
                borderRadius: BorderRadius.circular(18),
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    return Obx(() {
      final hasActiveFilters = controller.selectedSpecialtyId.value != null ||
          (controller.selectedWilaya.value != null &&
              controller.selectedWilaya.value!.isNotEmpty) ||
          controller.useLocation.value ||
          controller.searchQuery.value.isNotEmpty;

      if (!hasActiveFilters) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              if (controller.selectedSpecialtyId.value != null)
                _buildEpicFilterChip(
                  label: controller
                      .getSpecialtyName(controller.selectedSpecialtyId.value),
                  onDeleted: () => controller.filterBySpecialty(null),
                ),
              if (controller.selectedWilaya.value != null &&
                  controller.selectedWilaya.value!.isNotEmpty)
                _buildEpicFilterChip(
                  label: controller.selectedWilaya.value!,
                  onDeleted: () => controller.filterByWilaya(null),
                ),
              if (controller.useLocation.value)
                _buildEpicFilterChip(
                  label: 'À proximité',
                  onDeleted: () => controller.toggleNearbyFilter(),
                ),
              if (controller.searchQuery.value.isNotEmpty)
                _buildEpicFilterChip(
                  label: '"${controller.searchQuery.value}"',
                  onDeleted: () => controller.searchDoctorsByName(''),
                ),
              GestureDetector(
                onTap: controller.clearFilters,
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Effacer tout',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
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
    });
  }

  Widget _buildEpicFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6),
          GestureDetector(
            onTap: onDeleted,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DOCTORS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDoctorsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredDoctors.isEmpty) {
        return SliverFillRemaining(
          child: const LoadingIndicator(),
        );
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          ),
        );
      }
      if (controller.filteredDoctors.isEmpty) {
        return SliverFillRemaining(
          child: EmptyState(
            message: 'Aucun médecin trouvé',
            submessage: 'Essayez de modifier vos filtres',
            icon: Icons.medical_services_rounded,
            onRetry: controller.refreshData,
            retryText: 'Actualiser',
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.all(AppSpacing.md),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doctor = controller.filteredDoctors[index];
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: DoctorCard(
                  doctor: doctor,
                  onTap: () => controller.goToDoctorDetail(doctor.id),
                ),
              );
            },
            childCount: controller.filteredDoctors.length,
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // EPIC FILTER BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════

  void _showEpicFilterBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _EpicFilterBottomSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EPIC FILTER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _EpicFilterBottomSheet extends GetView<DoctorListController> {
  const _EpicFilterBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle and header
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primarySoft,
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtres',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Obx(() => Text(
                                    controller.getFilterSummary(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Sort options
                    _buildSection(
                      title: 'Trier par',
                      icon: Icons.sort_rounded,
                      child: Obx(() => Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildSortChip('Proximité', 'distance'),
                              _buildSortChip('Note', 'rating'),
                              _buildSortChip('Prix', 'fee'),
                              _buildSortChip('Expérience', 'experience'),
                            ],
                          )),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Specialty filter
                    _buildSection(
                      title: 'Spécialité',
                      icon: Icons.medical_services_rounded,
                      child: Obx(() {
                        if (controller.specialties.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildSpecialtyChip(
                              label: 'Toutes',
                              isSelected:
                                  controller.selectedSpecialtyId.value == null,
                              onTap: () => controller.filterBySpecialty(null),
                            ),
                            ...controller.specialties.map(
                              (specialty) => _buildSpecialtyChip(
                                label: specialty.nameFr,
                                isSelected:
                                    controller.selectedSpecialtyId.value ==
                                        specialty.id,
                                onTap: () =>
                                    controller.filterBySpecialty(specialty.id),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Nearby filter
                    _buildSection(
                      title: 'Localisation',
                      icon: Icons.near_me_rounded,
                      child: Obx(() => Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: controller.useLocation.value
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.primarySoft,
                                        AppColors.primarySoft.withOpacity(0.3),
                                      ],
                                    )
                                  : null,
                              color: controller.useLocation.value
                                  ? null
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: controller.useLocation.value
                                    ? AppColors.primary.withOpacity(0.3)
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: controller.useLocation.value
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.near_me_rounded,
                                    color: controller.useLocation.value
                                        ? Colors.white
                                        : AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'À proximité',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Médecins proches de vous',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: controller.useLocation.value,
                                  onChanged: (_) =>
                                      controller.toggleNearbyFilter(),
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          )),
                    ),

                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),

              // Apply button
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Voir les résultats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.sortBy.value == value;
      return GestureDetector(
        onTap: () {
          controller.changeSortBy(value);
          Navigator.pop(Get.context!);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 4,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSpecialtyChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md + 4,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WAVE PAINTER
// ═══════════════════════════════════════════════════════════════

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFF9FAFB)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.8,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
