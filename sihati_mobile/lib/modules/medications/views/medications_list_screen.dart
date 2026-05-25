import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import '../controllers/medications_list_controller.dart';

class MedicationsListScreen extends GetView<MedicationsListController> {
  const MedicationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
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
      expandedHeight: 148,
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
              top: 55,
              right: 55,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
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
                                'Médicaments',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    '${controller.medications.length} médicament${controller.medications.length > 1 ? 's' : ''} disponible${controller.medications.length > 1 ? 's' : ''}',
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
  // BODY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: LoadingIndicator(message: 'Chargement des médicaments...'),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshMedications,
          ),
        );
      }

      if (controller.medications.isEmpty) {
        return SliverFillRemaining(
          child: EmptyState(
            message: 'Aucun médicament trouvé',
            icon: Icons.medical_services_rounded,
            onRetry: controller.refreshMedications,
          ),
        );
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
              final medication = controller.medications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MedicationCard(
                  medication: medication,
                  onTap: () => controller.goToMedicationDetail(medication.id),
                ),
              );
            },
            childCount: controller.medications.length,
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// MEDICATION CARD
// ═══════════════════════════════════════════════════════════════

class _MedicationCard extends StatelessWidget {
  final dynamic medication;
  final VoidCallback onTap;

  const _MedicationCard({
    required this.medication,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCategory =
        medication.category != null && medication.category!.isNotEmpty;

    return _PressableWidget(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: AppColors.shadowSm,
        ),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon block
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primarySoftGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.medication,
                    width: AppSpacing.iconSizeMd,
                    height: AppSpacing.iconSizeMd,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary600,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: AppTextStyles.h6.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      medication.genericName ?? 'Aucun nom générique',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasCategory) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          medication.category!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary700,
                            fontSize: 11,
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
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.arrowForward,
                    width: 13,
                    height: 13,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textTertiary,
                      BlendMode.srcIn,
                    ),
                  ),
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
