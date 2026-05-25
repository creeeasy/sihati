import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.white,
        backgroundColor: AppColors.primary,
        displacement: 80,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMainServices(),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(() => controller.isGuestMode.value
                      ? _buildGuestBanner()
                      : const SizedBox.shrink()),
                  Obx(() => controller.isGuestMode.value
                      ? const SizedBox.shrink()
                      : _buildStats()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary800,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Deep gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.homeHeaderGradient,
              ),
            ),

            // Decorative circles
            Positioned(
              top: -30,
              right: -20,
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
              top: 40,
              right: 60,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary300.withOpacity(0.15),
                ),
              ),
            ),

            // Wave at bottom
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 36),
                painter: _SmoothWavePainter(color: AppColors.neutral50),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildGreeting()),
                    const SizedBox(width: AppSpacing.sm),
                    _buildHeaderAction(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final name = controller.userName.value;
          final isGuest = controller.isGuestMode.value;
          return Row(
            children: [
              Text(
                name.isNotEmpty
                    ? 'Bonjour, ${name.split(' ').first} 👋'
                    : 'Bonjour 👋',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              if (isGuest) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    'Invité',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
        const SizedBox(height: 6),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.18),
                borderRadius: AppSpacing.chipRadius,
                border: Border.all(
                  color: AppColors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Text(
                controller.greeting,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white.withOpacity(0.95),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildHeaderAction() {
    return Obx(() {
      final isGuest = controller.isGuestMode.value;
      return _PressableWidget(
        onTap: isGuest ? controller.logoutGuest : controller.goToProfile,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: AppColors.shadowMd,
          ),
          child: Center(
            child: SvgPicture.asset(
              isGuest ? AppIcons.logout : AppIcons.profile,
              width: AppSpacing.iconSizeMd,
              height: AppSpacing.iconSizeMd,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────

  Widget _buildSearchBar() {
    return _PressableWidget(
      onTap: controller.goToMedicationSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppSpacing.cardRadius,
          boxShadow: AppColors.shadowMd,
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: SvgPicture.asset(
                AppIcons.search,
                width: AppSpacing.iconSizeSm,
                height: AppSpacing.iconSizeSm,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Rechercher un médicament...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: AppColors.borderDefault,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            SvgPicture.asset(
              AppIcons.qrCode,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Accès rapide'),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 3.2,
          padding: EdgeInsets.zero,
          children: [
            _buildQuickActionCard(
              icon: AppIcons.medication,
              label: 'Médicaments',
              onTap: controller.goToAllMedications,
              isDisabled: false,
            ),
            Obx(() => _buildQuickActionCard(
                  icon: AppIcons.appointment,
                  label: 'Rendez-vous',
                  onTap: controller.goToMyAppointments,
                  isDisabled: controller.isGuestMode.value,
                )),
            _buildQuickActionCard(
              icon: AppIcons.favoriteFilled,
              label: 'Favoris',
              onTap: controller.goToFavorites,
              isDisabled: false,
            ),
            Obx(() => _buildQuickActionCard(
                  icon: AppIcons.medicalRecord,
                  label: 'Dossier médical',
                  onTap: controller.goToMedicalRecord,
                  isDisabled: controller.isGuestMode.value,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return _PressableWidget(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.neutral100 : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDisabled ? AppColors.borderDefault : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: isDisabled ? null : AppColors.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isDisabled ? null : AppColors.primarySoftGradient,
                color: isDisabled ? AppColors.neutral200 : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: AppSpacing.iconSizeSm,
                  height: AppSpacing.iconSizeSm,
                  colorFilter: ColorFilter.mode(
                    isDisabled ? AppColors.textTertiary : AppColors.primary600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDisabled
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isDisabled)
              SvgPicture.asset(
                AppIcons.lock,
                width: 12,
                height: 12,
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

  // ─────────────────────────────────────────────
  // MAIN SERVICES
  // ─────────────────────────────────────────────

  Widget _buildMainServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nos services'),
        const SizedBox(height: AppSpacing.sm),

        // AI Assistant — hero card
        _buildAIServiceCard(),
        const SizedBox(height: AppSpacing.sm),

        // Duty Pharmacies
        _buildServiceCard(
          icon: AppIcons.pharmacy,
          title: 'Pharmacies de garde',
          subtitle: 'Trouvez les pharmacies ouvertes maintenant',
          accentColor: AppColors.secondary,
          onTap: controller.goToDutyPharmacies,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Doctors + Pharmacies row
        Row(
          children: [
            Expanded(
              child: _buildCompactServiceCard(
                icon: AppIcons.doctor,
                title: 'Médecins',
                accentColor: AppColors.error,
                onTap: controller.goToDoctorList,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildCompactServiceCard(
                icon: AppIcons.hospital,
                title: 'Pharmacies',
                accentColor: AppColors.info,
                onTap: controller.goToPharmacyList,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIServiceCard() {
    return _PressableWidget(
      onTap: controller.goToAIAssistant,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppSpacing.cardRadius,
          boxShadow: AppColors.shadowPrimary,
        ),
        child: Row(
          children: [
            // Icon block
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.aiPsychology,
                  width: AppSpacing.iconSizeLg,
                  height: AppSpacing.iconSizeLg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Nouveau" badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.9),
                      borderRadius: AppSpacing.chipRadius,
                    ),
                    child: Text(
                      'Disponible 24h/24',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assistant Santé IA',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Posez vos questions santé en toute confiance',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.arrowForward,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return _PressableWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppSpacing.cardRadius,
          boxShadow: AppColors.shadowSm,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: AppSpacing.iconSizeMd,
                  height: AppSpacing.iconSizeMd,
                  colorFilter: ColorFilter.mode(
                    accentColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h6.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.arrowForward,
                  width: 14,
                  height: 14,
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
    );
  }

  Widget _buildCompactServiceCard({
    required String icon,
    required String title,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return _PressableWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppSpacing.cardRadius,
          boxShadow: AppColors.shadowSm,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: AppSpacing.iconSizeSm,
                  height: AppSpacing.iconSizeSm,
                  colorFilter: ColorFilter.mode(
                    accentColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GUEST BANNER
  // ─────────────────────────────────────────────

  Widget _buildGuestBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primaryDark.withOpacity(0.95),
          ],
        ),
        borderRadius: AppSpacing.cardRadius,
        boxShadow: AppColors.shadowPrimary,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: SvgPicture.asset(
              AppIcons.stethoscope,
              width: AppSpacing.iconSizeMd,
              height: AppSpacing.iconSizeMd,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Débloquez les rendez-vous',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Créez un compte gratuit pour accéder à toutes les fonctionnalités',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _PressableWidget(
            onTap: () => Get.toNamed(AppRoutes.REGISTER),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppSpacing.chipRadius,
              ),
              child: Text(
                "S'inscrire",
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATS (authenticated users)
  // ─────────────────────────────────────────────

  Widget _buildStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Aperçu'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppSpacing.cardRadius,
            boxShadow: AppColors.shadowSm,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Obx(() => _buildStatRow(
                icon: AppIcons.calendar,
                label: 'Rendez-vous à venir',
                value: controller.upcomingAppointments.value.toString(),
                onTap: controller.goToMyAppointments,
              )),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppSpacing.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.cardRadius,
        splashColor: AppColors.primarySoft,
        highlightColor: AppColors.primarySoft.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primarySoftGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Voir tous vos rendez-vous',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SvgPicture.asset(
                AppIcons.arrowForward,
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Row(
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
          title,
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PRESS ANIMATION WRAPPER
// ─────────────────────────────────────────────

class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableWidget({required this.child, this.onTap});

  @override
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
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

// ─────────────────────────────────────────────
// WAVE PAINTER
// ─────────────────────────────────────────────

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
