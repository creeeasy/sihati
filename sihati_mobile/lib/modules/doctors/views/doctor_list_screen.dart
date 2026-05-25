import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
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
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchSection()),
          SliverToBoxAdapter(child: _buildTopRatedStrip()),
          SliverToBoxAdapter(child: _buildSpecialtyQuickRow()),
          SliverToBoxAdapter(child: _buildActiveFilterBar()),
          SliverToBoxAdapter(child: _buildListHeader()),
          _buildDoctorsList(),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  // ─── Sliver App Bar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary700,
      // Back button
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.arrowBack,
                width: AppSpacing.iconSizeMd,
                height: AppSpacing.iconSizeMd,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: SvgPicture.asset(
                AppIcons.filter,
                width: AppSpacing.iconSizeMd,
                height: AppSpacing.iconSizeMd,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: _buildAppBarBackground(),
      ),
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.homeHeaderGradient),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: 40,
            right: -40,
            child: _decorCircle(140, 0.08),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: _decorCircle(90, 0.06),
          ),
          Positioned(
            bottom: 30,
            right: 60,
            child: _decorCircle(50, 0.1),
          ),
          // Wave at bottom
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(Get.width, 44),
              painter: _WavePainter(),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
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
                      // Icon badge
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm + 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.doctor,
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Médecins',
                              style: AppTextStyles.displaySmall
                                  .copyWith(color: Colors.white, height: 1.1),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Trouvez votre spécialiste',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Count badge
                      Obx(() =>
                          _buildCountBadge(controller.filteredDoctors.length)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.verified,
            width: 13,
            height: 13,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            '$count médecin${count > 1 ? 's' : ''}',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  // ─── Search ──────────────────────────────────────────────────────────────────

  Widget _buildSearchSection() {
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderDefault, width: 1.5),
          boxShadow: AppColors.shadowMd,
        ),
        child: Obx(() => TextField(
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rechercher un médecin...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textTertiary),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: controller.isNameSearchLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : SvgPicture.asset(
                          AppIcons.search,
                          colorFilter: const ColorFilter.mode(
                              AppColors.primary, BlendMode.srcIn),
                        ),
                ),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        onPressed: () => controller.searchDoctorsByName(''),
                        icon: SvgPicture.asset(
                          AppIcons.close,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary, BlendMode.srcIn),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
              ),
              onChanged: controller.searchDoctorsByName,
            )),
      ),
    );
  }

  // ─── Top-Rated Strip ─────────────────────────────────────────────────────────

  Widget _buildTopRatedStrip() {
    return Obx(() {
      if (controller.hasActiveFilters) return const SizedBox.shrink();
      if (controller.isTopRatedLoading.value) {
        return const SizedBox(
          height: 148,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      }
      if (controller.topRatedDoctors.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning50,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                        color: AppColors.warning500.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppIcons.starFilled,
                        width: 15,
                        height: 15,
                        colorFilter: const ColorFilter.mode(
                            AppColors.warning500, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Mieux notés',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.warning700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 136,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.topRatedDoctors.length,
              itemBuilder: (context, index) {
                final doc = controller.topRatedDoctors[index];
                return _TopRatedCard(
                  doctor: doc,
                  onTap: () => controller.goToDoctorDetail(doc.id),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(
              color: AppColors.neutral200,
              height: 1,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
        ],
      );
    });
  }

  // ─── Specialty Chips ─────────────────────────────────────────────────────────

  Widget _buildSpecialtyQuickRow() {
    return Obx(() {
      if (controller.specialties.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xs),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.stethoscope,
                  width: AppSpacing.iconSizeSm,
                  height: AppSpacing.iconSizeSm,
                  colorFilter: const ColorFilter.mode(
                      AppColors.primary, BlendMode.srcIn),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Spécialités',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              physics: const BouncingScrollPhysics(),
              children: [
                _SpecialtyChip(
                  label: 'Tous',
                  isSelected: controller.selectedSpecialtyId.value == null,
                  onTap: () => controller.filterBySpecialty(null),
                ),
                const SizedBox(width: AppSpacing.xs),
                ...controller.specialties.map((s) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: _SpecialtyChip(
                        label: s.nameFr,
                        isSelected:
                            controller.selectedSpecialtyId.value == s.id,
                        onTap: () => controller.filterBySpecialty(s.id),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      );
    });
  }

  // ─── Active Filter Bar ───────────────────────────────────────────────────────

  Widget _buildActiveFilterBar() {
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              if (controller.selectedSpecialtyId.value != null)
                _FilterPill(
                  label: controller
                      .getSpecialtyName(controller.selectedSpecialtyId.value),
                  onDelete: () => controller.filterBySpecialty(null),
                ),
              if (controller.selectedWilaya.value?.isNotEmpty == true)
                _FilterPill(
                  label: controller.selectedWilaya.value!,
                  onDelete: () => controller.filterByWilaya(null),
                ),
              if (controller.useLocation.value)
                _FilterPill(
                  label: 'À proximité',
                  onDelete: controller.toggleNearbyFilter,
                ),
              if (controller.searchQuery.value.isNotEmpty)
                _FilterPill(
                  label: '"${controller.searchQuery.value}"',
                  onDelete: () => controller.searchDoctorsByName(''),
                ),
              const SizedBox(width: AppSpacing.xs),
              // Clear all
              _ClearAllButton(onTap: controller.clearFilters),
            ],
          ),
        ),
      );
    });
  }

  // ─── List Header ─────────────────────────────────────────────────────────────

  Widget _buildListHeader() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxs),
          child: Row(
            children: [
              Text(
                controller.viewModeLabel,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (controller.isLoading.value)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ));
  }

  // ─── Doctors List ────────────────────────────────────────────────────────────

  Widget _buildDoctorsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredDoctors.isEmpty) {
        return const SliverFillRemaining(child: LoadingIndicator());
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
            submessage: 'Essayez de modifier vos filtres de recherche',
            icon: Icons.medical_services_rounded,
            onRetry: controller.refreshData,
            retryText: 'Actualiser',
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doctor = controller.filteredDoctors[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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

  // ─── Filter Bottom Sheet ─────────────────────────────────────────────────────

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(controller: controller),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String _formatName(String name) {
    if (name.startsWith('Dr') || name.startsWith('DR')) return name;
    return 'Dr. $name';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Private Extracted Widgets
// ═════════════════════════════════════════════════════════════════════════════

/// Top-rated horizontal card
class _TopRatedCard extends StatefulWidget {
  final dynamic doctor;
  final VoidCallback onTap;
  const _TopRatedCard({required this.doctor, required this.onTap});

  @override
  State<_TopRatedCard> createState() => _TopRatedCardState();
}

class _TopRatedCardState extends State<_TopRatedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 210,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          padding: AppSpacing.cardPaddingSmall,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(
              color: AppColors.warning200.withOpacity(0.7),
              width: 1.5,
            ),
            boxShadow: _pressed
                ? AppColors.shadowLg
                : [
                    BoxShadow(
                      color: AppColors.warning500.withOpacity(0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary50,
                    child: Text(
                      DoctorListScreen._initials(doc.doctorName),
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DoctorListScreen._formatName(doc.doctorName),
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Specialty pill
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            doc.specialty?.nameFr ?? 'Spécialiste',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.starFilled,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                        AppColors.warning500, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doc.averageRating?.toStringAsFixed(1) ?? '—',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.warning700),
                  ),
                  if (doc.totalReviews != null) ...[
                    const SizedBox(width: 3),
                    Text(
                      '(${doc.totalReviews})',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                  const Spacer(),
                  if (doc.consultationFee != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success50,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                      child: Text(
                        '${doc.consultationFee!.toStringAsFixed(0)} DA',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.success700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs + 2),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.location,
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                        AppColors.error, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      doc.wilaya ?? '',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated specialty chip
class _SpecialtyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SpecialtyChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 3),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceCard,
          borderRadius: AppSpacing.chipRadius,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderDefault,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppColors.shadowPrimary : AppColors.shadowXs,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Active filter pill
class _FilterPill extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  const _FilterPill({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 2),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.chipRadius,
        boxShadow: AppColors.shadowPrimary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textOnPrimary),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.close,
                width: 12,
                height: 12,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clear all filters button
class _ClearAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 2),
        decoration: BoxDecoration(
          color: AppColors.error50,
          borderRadius: AppSpacing.chipRadius,
          border: Border.all(color: AppColors.error500.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.close,
              width: 13,
              height: 13,
              colorFilter:
                  const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              'Effacer',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Filter Bottom Sheet
// ═════════════════════════════════════════════════════════════════════════════

class _FilterBottomSheet extends StatelessWidget {
  final DoctorListController controller;
  const _FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              _buildSheetHeader(),
              // Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _buildSection(
                      title: 'Trier par',
                      icon: AppIcons.filter,
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _buildSortChip('Proximité', 'distance'),
                          _buildSortChip('Note', 'rating'),
                          _buildSortChip('Prix', 'fee'),
                          _buildSortChip('Expérience', 'experience'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(
                      title: 'Wilaya',
                      icon: AppIcons.location,
                      child: _buildWilayaSelector(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(
                      title: 'Localisation',
                      icon: AppIcons.location,
                      child: _buildLocationToggle(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              // CTA
              _buildSheetCTA(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary50, AppColors.surfaceCard],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: AppColors.shadowPrimary,
                ),
                child: SvgPicture.asset(
                  AppIcons.filter,
                  width: 20,
                  height: 20,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtres avancés', style: AppTextStyles.h5),
                    Obx(() => Text(
                          controller.getFilterSummary(),
                          style: AppTextStyles.bodySmall,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheetCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        boxShadow: AppColors.shadowMd,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppSpacing.buttonRadius,
              boxShadow: AppColors.shadowPrimary,
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonRadius),
              ),
              child: Text(
                'Voir les résultats',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textOnPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              width: AppSpacing.iconSizeSm,
              height: AppSpacing.iconSizeSm,
              colorFilter:
                  const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(title, style: AppTextStyles.h6),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.borderDefault,
              width: 1.5,
            ),
            boxShadow:
                isSelected ? AppColors.shadowPrimary : AppColors.shadowXs,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWilayaSelector(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.selectedWilaya.value != null)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(AppIcons.location,
                        width: 15,
                        height: 15,
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn)),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(controller.selectedWilaya.value!,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => controller.filterByWilaya(null),
                      child: SvgPicture.asset(AppIcons.close,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              AppColors.primary, BlendMode.srcIn)),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: () => _showWilayaDialog(context),
              child: Container(
                padding: AppSpacing.inputPadding,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(AppIcons.location,
                        width: AppSpacing.iconSizeMd,
                        height: AppSpacing.iconSizeMd,
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        controller.selectedWilaya.value ?? 'Choisir une wilaya',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: controller.selectedWilaya.value != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildLocationToggle() {
    return Obx(() => GestureDetector(
          onTap: controller.toggleNearbyFilter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: controller.useLocation.value
                  ? AppColors.primarySoft
                  : AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: controller.useLocation.value
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.borderDefault,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    gradient: controller.useLocation.value
                        ? AppColors.primaryGradient
                        : null,
                    color: controller.useLocation.value
                        ? null
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    boxShadow: controller.useLocation.value
                        ? AppColors.shadowPrimary
                        : null,
                  ),
                  child: Icon(
                    Icons.near_me_rounded,
                    color: controller.useLocation.value
                        ? Colors.white
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('À proximité', style: AppTextStyles.labelLarge),
                      Text(
                        'Médecins proches de votre position',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: controller.useLocation.value,
                  onChanged: (_) => controller.toggleNearbyFilter(),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ));
  }

  void _showWilayaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          constraints: BoxConstraints(maxHeight: Get.height * 0.65),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: SvgPicture.asset(AppIcons.location,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Choisir une wilaya', style: AppTextStyles.h5),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.borderDefault),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.algerianWilayas.length,
                  itemBuilder: (context, index) {
                    final wilaya = controller.algerianWilayas[index];
                    final isSelected =
                        controller.selectedWilaya.value == wilaya;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(Get.context!);
                        controller.filterByWilaya(wilaya);
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                        margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySoft
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
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
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                wilaya,
                                style: AppTextStyles.bodyMedium.copyWith(
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

// ═════════════════════════════════════════════════════════════════════════════
// Wave Painter
// ═════════════════════════════════════════════════════════════════════════════

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neutral50
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.15,
          size.width * 0.5, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.95, size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
