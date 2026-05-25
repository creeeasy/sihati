import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/models/medication_model.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import '../controllers/medication_search_controller.dart';

class MedicationSearchScreen extends GetView<MedicationSearchController> {
  const MedicationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildSuggestionChips()),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140,
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
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: _PressableWidget(
            onTap: controller.clearSearch,
            child: Container(
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
                    AppIcons.close,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Effacer',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      fontSize: 11,
                    ),
                  ),
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
            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.homeHeaderGradient,
              ),
            ),

            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 55,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.2),
                ),
              ),
            ),

            // Wave
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
                            AppIcons.medication,
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
                                'Recherche',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull),
                                  border: Border.all(
                                    color: AppColors.white.withOpacity(0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      AppIcons.pharmacy,
                                      width: 11,
                                      height: 11,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Trouvez votre médicament',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
  // SEARCH BAR — hero element
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: Container(
              height: AppSpacing.buttonHeight,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.borderLight, width: 1),
                boxShadow: AppColors.shadowMd,
              ),
              child: TextField(
                controller: controller.searchController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => controller.searchMedication(),
                decoration: InputDecoration(
                  hintText: 'Nom du médicament...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SvgPicture.asset(
                      AppIcons.search,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Search button
          Obx(() => _PressableWidget(
                onTap: controller.isLoading.value
                    ? null
                    : controller.searchMedication,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: AppSpacing.buttonHeight,
                  height: AppSpacing.buttonHeight,
                  decoration: BoxDecoration(
                    gradient: controller.isLoading.value
                        ? null
                        : AppColors.primaryGradient,
                    color: controller.isLoading.value
                        ? AppColors.neutral200
                        : null,
                    borderRadius: AppSpacing.cardRadius,
                    boxShadow: controller.isLoading.value
                        ? null
                        : AppColors.shadowPrimary,
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          )
                        : SvgPicture.asset(
                            AppIcons.arrowForward,
                            width: AppSpacing.iconSizeMd,
                            height: AppSpacing.iconSizeMd,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUGGESTION CHIPS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSuggestionChips() {
    const suggestions = ['Doliprane', 'Nurofen', 'Aspirine', 'Amoxicilline'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: suggestions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: _SuggestionChip(
                      label: s,
                      onTap: () {
                        controller.searchController.text = s;
                        controller.searchMedication();
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTENT — state router
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return Obx(() {
      if (!controller.hasSearched.value) return _buildInitialState();

      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: AppSpacing.xxl),
          child: LoadingIndicator(message: 'Recherche en cours...'),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return ErrorDisplayWidget(
          message: controller.errorMessage.value,
          onRetry: controller.searchMedication,
        );
      }

      if (controller.searchResults.isEmpty) {
        return EmptyState(
          message: 'Aucun médicament trouvé',
          submessage: 'Essayez un autre nom ou vérifiez l\'orthographe',
          icon: AppIcons.medication,
          onRetry: controller.searchMedication,
          retryText: 'Réessayer',
        );
      }

      return _buildResultsList();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // INITIAL STATE — warm, inviting, instructive
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      child: Column(
        children: [
          // Hero illustration block
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.primarySoftGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SvgPicture.asset(
              AppIcons.medication,
              width: 52,
              height: 52,
              colorFilter: const ColorFilter.mode(
                AppColors.primary600,
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Recherchez un médicament',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Trouvez les pharmacies qui disposent\ndu médicament en stock près de vous',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tips card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppSpacing.cardRadius,
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: AppColors.shadowSm,
            ),
            child: Column(
              children: [
                // Card header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.info,
                          width: AppSpacing.iconSizeSm,
                          height: AppSpacing.iconSizeSm,
                          colorFilter: const ColorFilter.mode(
                            AppColors.warning,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Exemples de recherche',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.neutral100, height: 1),

                // Example items
                _buildExampleRow('Doliprane 1000mg', isFirst: true),
                Divider(
                    color: AppColors.neutral100,
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md),
                _buildExampleRow('Nurofen 400mg'),
                Divider(
                    color: AppColors.neutral100,
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md),
                _buildExampleRow('Aspirine', isLast: true),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Pro tip pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppIcons.info,
                  width: 13,
                  height: 13,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Vous pouvez aussi scanner l\'ordonnance',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                SvgPicture.asset(
                  AppIcons.qrCode,
                  width: 13,
                  height: 13,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleRow(String text,
      {bool isFirst = false, bool isLast = false}) {
    return _PressableWidget(
      onTap: () {
        controller.searchController.text = text;
        controller.searchMedication();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(0) : Radius.zero,
            bottom: isLast ? Radius.circular(AppSpacing.radiusLg) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primarySoftGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.search,
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SvgPicture.asset(
              AppIcons.arrowForward,
              width: 13,
              height: 13,
              colorFilter: const ColorFilter.mode(
                AppColors.textTertiary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RESULTS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildResultsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results banner
          _buildResultsBanner(),
          const SizedBox(height: AppSpacing.md),

          // Section header
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Résultats',
                style: AppTextStyles.h5.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Cards
          ...controller.searchResults.asMap().entries.map((entry) {
            final index = entry.key;
            final medication = entry.value;
            return _AnimatedResultCard(
              medication: medication,
              index: index,
              onTap: () => controller.goToMedicationDetail(medication.id),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultsBanner() {
    return Container(
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
              AppIcons.verified,
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
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.searchResults.length} résultat${controller.searchResults.length > 1 ? 's' : ''} trouvé${controller.searchResults.length > 1 ? 's' : ''}',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.success700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Appuyez sur un médicament pour voir le stock',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success700.withOpacity(0.8),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED RESULT CARD — staggered entrance
// ═══════════════════════════════════════════════════════════════

class _AnimatedResultCard extends StatefulWidget {
  final MedicationModel medication;
  final int index;
  final VoidCallback onTap;

  const _AnimatedResultCard({
    required this.medication,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedResultCard> createState() => _AnimatedResultCardState();
}

class _AnimatedResultCardState extends State<_AnimatedResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger based on index
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _PressableWidget(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: AppSpacing.cardRadius,
                // Old code style: Left border only
                border: const Border(
                  left: BorderSide(
                    color: AppColors.primary,
                    width: 4,
                  ),
                ),
                boxShadow: AppColors.shadowSm,
              ),
              child: Padding(
                padding:
                    AppSpacing.paddingCard, // Reverted to old padding variable
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft, // Reverted from gradient
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons.medication,
                          width: AppSpacing.iconSizeMd,
                          height: AppSpacing.iconSizeMd,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary, // Reverted to base primary
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.medication.name,
                            style: AppTextStyles
                                .title, // Simplified to match old text style logic
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.medication.genericName != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.medication.genericName!,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (widget.medication.category != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withOpacity(0.1), // Old style background
                                borderRadius: AppSpacing
                                    .chipRadius, // Reverted to old border radius style
                              ),
                              child: Text(
                                widget.medication.category!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors
                                      .primary, // Reverted from primary700
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Arrow
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.divider, // Reverted from neutral100
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppIcons
                              .arrowForward, // Assuming you have this in AppIcons
                          width: 13,
                          height: 13,
                          colorFilter: const ColorFilter.mode(
                            AppColors
                                .textSecondary, // Reverted from textTertiary
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════
// SUGGESTION CHIP
// ═══════════════════════════════════════════════════════════════

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressableWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs - 1,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1.5,
          ),
          boxShadow: AppColors.shadowXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.info,
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppColors.warning,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
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
