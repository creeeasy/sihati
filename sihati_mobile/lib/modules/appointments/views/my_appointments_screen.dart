import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';

import '../controllers/my_appointments_controller.dart';
import 'widgets/appointment_card.dart';

class MyAppointmentsScreen extends GetView<MyAppointmentsController> {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(
            message: 'Chargement des rendez-vous...',
          );
        }

        return NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (_, __) => [
            _buildHeader(),
            _buildStickyTabs(),
          ],
          body: Obx(() {
            final isUpcoming = controller.selectedTab.value == 0;

            return _buildAppointmentsList(
              isUpcoming
                  ? controller.upcomingAppointments
                  : controller.pastAppointments,
              isUpcoming: isUpcoming,
            );
          }),
        );
      }),
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
      title: const SizedBox.shrink(),
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: _PressableWidget(
          onTap: () => Get.back(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusSm,
              ),
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
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.homeHeaderGradient,
              ),
            ),
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
              right: 58,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 32),
                painter: _SmoothWavePainter(
                  color: AppColors.neutral50,
                ),
              ),
            ),
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
                          padding: const EdgeInsets.all(
                            AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.appointment,
                            width: AppSpacing.iconSizeLg,
                            height: AppSpacing.iconSizeLg,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.md,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes Rendez-vous',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Obx(() {
                                final upcoming =
                                    controller.upcomingAppointments.length;

                                return Text(
                                  upcoming > 0
                                      ? '$upcoming rendez-vous à venir'
                                      : 'Aucun rendez-vous à venir',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }),
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
  // STICKY TABS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStickyTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        child: Obx(
          () => _TabBar(
            upcomingCount: controller.upcomingAppointments.length,
            pastCount: controller.pastAppointments.length,
            selectedIndex: controller.selectedTab.value,
            onTabSelected: (i) {
              controller.selectedTab.value = i;
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAppointmentsList(
    List appointments, {
    required bool isUpcoming,
  }) {
    if (appointments.isEmpty) {
      return EmptyState(
        message: isUpcoming
            ? 'Aucun rendez-vous à venir'
            : 'Aucun rendez-vous passé',
        submessage: isUpcoming
            ? 'Prenez rendez-vous avec un médecin'
            : 'Vos consultations passées apparaîtront ici',
        icon: Icons.event_busy_rounded,
        onRetry: isUpcoming ? controller.refreshAppointments : null,
        retryText: 'Actualiser',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAppointments,
      color: AppColors.white,
      backgroundColor: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _AnimatedAppointmentItem(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: AppointmentCard(
                appointment: appointments[index],
                onCancel: isUpcoming
                    ? () => controller.cancelAppointment(
                          appointments[index],
                        )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB BAR
// ═══════════════════════════════════════════════════════════════

class _TabBar extends StatelessWidget {
  final int upcomingCount;
  final int pastCount;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _TabBar({
    required this.upcomingCount,
    required this.pastCount,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _TabBarDelegate.height,
      child: Container(
        color: AppColors.neutral50,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusMd,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _buildTab(
                index: 0,
                icon: AppIcons.calendar,
                label: 'À venir',
                count: upcomingCount,
                isSelected: selectedIndex == 0,
              ),
              _buildTab(
                index: 1,
                icon: AppIcons.history,
                label: 'Passés',
                count: pastCount,
                isSelected: selectedIndex == 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required String icon,
    required String label,
    required int count,
    required bool isSelected,
  }) {
    return Expanded(
      child: _PressableWidget(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusSm,
            ),
            boxShadow: isSelected ? AppColors.shadowSm : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 15,
                height: 15,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : AppColors.neutral300,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusFull,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          isSelected ? AppColors.white : AppColors.neutral600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB BAR DELEGATE
// ═══════════════════════════════════════════════════════════════

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _TabBarDelegate({
    required this.child,
  });

  static const double height = AppSpacing.xs + 48 + AppSpacing.sm;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      shadowColor: AppColors.black.withOpacity(0.06),
      color: AppColors.neutral50,
      child: SizedBox(
        height: height,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant _TabBarDelegate oldDelegate,
  ) {
    return oldDelegate.child != child;
  }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED LIST ITEM
// ═══════════════════════════════════════════════════════════════

class _AnimatedAppointmentItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedAppointmentItem({
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedAppointmentItem> createState() =>
      _AnimatedAppointmentItemState();
}

class _AnimatedAppointmentItemState extends State<_AnimatedAppointmentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 380,
      ),
    );

    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      Duration(
        milliseconds: 55 * widget.index,
      ),
      () {
        if (mounted) {
          _ctrl.forward();
        }
      },
    );
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
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRESSABLE WIDGET
// ═══════════════════════════════════════════════════════════════

class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableWidget({
    required this.child,
    this.onTap,
  });

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
      duration: const Duration(
        milliseconds: 100,
      ),
      reverseDuration: const Duration(
        milliseconds: 200,
      ),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
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

  const _SmoothWavePainter({
    required this.color,
  });

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
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant _SmoothWavePainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
