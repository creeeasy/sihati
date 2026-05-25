// lib/modules/profile/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshUserData,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: Obx(() {
          if (controller.isLoading.value && controller.user.value == null) {
            return const LoadingIndicator();
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.user.value == null) {
            return ErrorDisplayWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadProfile,
            );
          }
          if (controller.user.value == null) {
            return Center(
              child: Text('Utilisateur non trouvé',
                  style:
                      TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            );
          }
          return _buildContent();
        }),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        _buildHeader(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl + 8, AppSpacing.lg, AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildNameBadge(),
              const SizedBox(height: AppSpacing.lg),
              _buildMedicalRecordCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickActionsCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildChifaCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildPersonalInfoCard(),
              const SizedBox(height: AppSpacing.md),
              _buildLogoutButton(),
              const SizedBox(height: AppSpacing.md),
            ]),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WAVE HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(
            AppIcons.arrowBack,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Obx(() => IconButton(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  controller.isEditing.value ? AppIcons.close : AppIcons.edit,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: controller.toggleEditMode,
              )),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.profileWaveGradient,
              ),
            ),
            Positioned(
              top: -40,
              right: -30,
              child: _Circle(size: 150, opacity: 0.08),
            ),
            Positioned(
              top: 70,
              left: -20,
              child: _Circle(size: 90, opacity: 0.06),
            ),
            Positioned(
              bottom: 40,
              right: 60,
              child: _Circle(
                  size: 60, opacity: 0.10, color: const Color(0xFF64FFDA)),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: const Size(double.infinity, 30),
                painter: _WavePainter(),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Obx(() {
                  final user = controller.user.value;
                  return Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user != null ? controller.getUserInitials() : '--',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // NAME + ROLE BADGE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildNameBadge() {
    return Obx(() {
      final user = controller.user.value!;
      return Column(
        children: [
          Text(user.fullName,
              style: AppTextStyles.displayMedium
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppSpacing.chipRadius,
            ),
            child: Text(controller.getUserRole(),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // DOSSIER MÉDICAL CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMedicalRecordCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.goToMedicalRecord(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.medicalRecord,
                        width: 32, height: 32,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mon Dossier Médical',
                              style: AppTextStyles.h5.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Accédez à votre historique complet',
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      AppIcons.arrowForward,
                      width: 16, height: 16,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _buildMedicalStatItem(
                        svgIcon: AppIcons.prescription,
                        count: controller.prescriptionsCount.value.toString(),
                        label: 'Ordonnances',
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3)),
                    Expanded(
                      child: _buildMedicalStatItem(
                        svgIcon: AppIcons.medication,
                        count: controller.medicationsCount.value.toString(),
                        label: 'Médicaments',
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3)),
                    Expanded(
                      child: _buildMedicalStatItem(
                        svgIcon: AppIcons.calendar,
                        count: controller.consultationsCount.value.toString(),
                        label: 'Consultations',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalStatItem(
      {required String svgIcon, required String count, required String label}) {
    return Column(
      children: [
        SvgPicture.asset(
          svgIcon,
          width: 22, height: 22,
          colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.srcIn),
        ),
        const SizedBox(height: 6),
        Text(count,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIONS RAPIDES CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuickActionsCard() {
    return _Card(
      title: 'Actions rapides',
      child: Column(
        children: [
          _ActionTile(
            svgIcon: AppIcons.favoriteFilled,
            title: 'Mes Favoris',
            subtitle: 'Pharmacies et médecins sauvegardés',
            onTap: controller.goToFavorites,
          ),
          const Divider(height: 1, color: AppColors.divider),
          _ActionTile(
            svgIcon: AppIcons.appointment,
            title: 'Mes Rendez-vous',
            subtitle: 'Consultations à venir',
            onTap: controller.goToAppointments,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARTE CHIFA CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildChifaCard() {
    return _Card(
      title: 'Carte Chifa',
      child: Obx(() {
        final hasChifa = controller.user.value?.hasChifa ?? false;
        final chifaNumber = controller.user.value?.chifaNumber;

        return Column(
          children: [
            _ChifaTile(
              svgIcon: AppIcons.qrCode,
              title: 'Numéro Carte Chifa',
              value:
                  hasChifa ? _formatChifaNumber(chifaNumber!) : 'Non renseigné',
              subtitle: hasChifa
                  ? 'Carte nationale de sécurité sociale'
                  : 'Ajoutez votre numéro pour faciliter vos démarches',
              isVerified: hasChifa,
              onTap: () => _showEditChifaDialog(),
            ),
            if (!hasChifa)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                     children: [
                       SvgPicture.asset(AppIcons.info, width: 18, height: 18,
                         colorFilter: const ColorFilter.mode(AppColors.info, BlendMode.srcIn)),
                       const SizedBox(width: 10),
                       Expanded(
                         child: Text(
                           'Le numéro Chifa vous permet de bénéficier de remboursements et d\'accéder à vos droits',
                           style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.info),
                         ),
                       ),
                     ],
                   ),
                ),
              ),
          ],
        );
      }),
    );
  }

  String _formatChifaNumber(String chifa) {
    String clean = chifa.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 3 == 0) formatted += ' ';
      formatted += clean[i];
    }
    return formatted;
  }

  void _showEditChifaDialog() {
    final chifaController =
        TextEditingController(text: controller.user.value?.chifaNumber ?? '');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            SvgPicture.asset(AppIcons.qrCode, width: 22, height: 22,
              colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            const SizedBox(width: 12),
            const Text('Carte Chifa',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numéro de Carte Chifa',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: chifaController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15)
              ],
              decoration: InputDecoration(
                hintText: '1234567890123',
                prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(AppIcons.qrCode, width: 20, height: 20,
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SvgPicture.asset(AppIcons.info, width: 14, height: 14,
                  colorFilter: const ColorFilter.mode(AppColors.info, BlendMode.srcIn)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Entre 13 et 15 chiffres (Optionnel)',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
              ],
            ),
            if (controller.user.value?.hasChifa ?? false) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.divider),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Get.back();
                  _confirmDeleteChifa();
                },
                child: Row(
                  children: [
                    SvgPicture.asset(AppIcons.delete, width: 18, height: 18,
                      colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn)),
                    const SizedBox(width: 8),
                    Text('Supprimer le numéro',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              final chifa = chifaController.text.replaceAll(' ', '');
              if (chifa.isEmpty || (chifa.length >= 13 && chifa.length <= 15)) {
                controller.updateChifaNumber(chifa);
                Get.back();
              } else {
                Get.snackbar('Erreur', 'Format invalide (13-15 chiffres)',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChifa() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le numéro Chifa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre numéro Carte Chifa ?',
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              controller.updateChifaNumber('');
              Get.back();
              Get.back();
            },
            child: Text('Supprimer',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PERSONAL INFO CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPersonalInfoCard() {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      return _Card(
        title: 'Informations personnelles',
        child: Column(
          children: [
            _FieldRow(
              label: 'Email',
              child: CustomTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'email@exemple.com',
                prefixSvg: AppIcons.notification,
                enabled: false,
                readOnly: true,
              ),
            ),
            _FieldRow(
              label: 'Nom complet',
              child: CustomTextField(
                controller: controller.fullNameController,
                label: 'Nom complet',
                hint: 'Votre nom complet',
                prefixSvg: AppIcons.profile,
                enabled: isEditing,
                readOnly: !isEditing,
              ),
            ),
            _FieldRow(
              label: 'Téléphone',
              child: CustomTextField(
                controller: controller.phoneController,
                label: 'Téléphone',
                hint: '0550 12 34 56',
                prefixSvg: AppIcons.phone,
                keyboardType: TextInputType.phone,
                enabled: isEditing,
                readOnly: !isEditing,
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return _MessageBanner(
                      message: controller.errorMessage.value, isError: true);
                }
                if (controller.successMessage.value.isNotEmpty) {
                  return _MessageBanner(
                      message: controller.successMessage.value, isError: false);
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.updateProfile,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white)),
                                )
                              : const Text('Enregistrer les modifications',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT BUTTON
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: controller.showLogoutConfirmation,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.error,
        minimumSize: const Size.fromHeight(52),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.logout,
            width: 20, height: 20,
            colorFilter: const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          const Text(
            'Se déconnecter',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REUSABLE COMPONENTS
// ═══════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          child,
        ],
      ),
    );
  }
}

class _ChifaTile extends StatelessWidget {
  final String svgIcon;
  final String title;
  final String value;
  final String subtitle;
  final bool isVerified;
  final VoidCallback onTap;
  const _ChifaTile({
    required this.svgIcon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isVerified ? AppColors.successLight : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgIcon,
                  width: 22, height: 22,
                  colorFilter: ColorFilter.mode(
                    isVerified ? AppColors.success : AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        SvgPicture.asset(AppIcons.verified, width: 14, height: 14,
                          colorFilter: const ColorFilter.mode(AppColors.success, BlendMode.srcIn)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isVerified ? AppColors.textPrimary : AppColors.info)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            SvgPicture.asset(AppIcons.arrowForward, width: 16, height: 16,
              colorFilter: const ColorFilter.mode(AppColors.textTertiary, BlendMode.srcIn)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String svgIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.svgIcon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgIcon,
                  width: 22, height: 22,
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            SvgPicture.asset(AppIcons.arrowForward, width: 16, height: 16,
              colorFilter: const ColorFilter.mode(AppColors.textTertiary, BlendMode.srcIn)),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: child,
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? AppColors.error.withOpacity(0.4)
              : AppColors.success.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            isError ? AppIcons.errorIcon : AppIcons.verified,
            width: 18, height: 18,
            colorFilter: ColorFilter.mode(
              isError ? AppColors.error : AppColors.success,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: isError ? AppColors.errorDark : AppColors.successDark)),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;
  const _Circle(
      {required this.size, required this.opacity, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: color.withOpacity(opacity)),
    );
  }
}

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
