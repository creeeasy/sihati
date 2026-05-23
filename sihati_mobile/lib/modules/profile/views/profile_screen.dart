// lib/modules/profile/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
              _buildSettingsCard(),
              const SizedBox(height: AppSpacing.md),
              _buildAboutCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildLogoutButton(),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text('v1.0.0',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textTertiary)),
              ),
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
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 18),
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
                icon: Icon(
                  controller.isEditing.value
                      ? Icons.close_rounded
                      : Icons.edit_rounded,
                  color: Colors.white,
                  size: 18,
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E7BF6),
                    Color(0xFF1E5BC6),
                    Color(0xFF0D2460)
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
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
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(controller.getUserRole(),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
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
                      child: const Icon(Icons.medical_information_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mon Dossier Médical',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Accédez à votre historique complet',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 18),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _buildMedicalStatItem(
                        icon: Icons.description_outlined,
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
                        icon: Icons.medication_outlined,
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
                        icon: Icons.calendar_today_outlined,
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
      {required IconData icon, required String count, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        const SizedBox(height: 6),
        Text(count,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8)),
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
            icon: Icons.bookmark_outlined,
            title: 'Mes Favoris',
            subtitle: 'Pharmacies et médecins sauvegardés',
            onTap: controller.goToFavorites,
          ),
          const Divider(height: 1, color: AppColors.divider),
          _ActionTile(
            icon: Icons.event_outlined,
            title: 'Mes Rendez-vous',
            subtitle: 'Consultations à venir',
            onTap: controller.goToAppointments,
          ),
          const Divider(height: 1, color: AppColors.divider),
          _ActionTile(
            icon: Icons.alarm_outlined,
            title: 'Mes Rappels',
            subtitle: 'Médicaments et rendez-vous',
            onTap: controller.goToReminders,
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
              icon: Icons.credit_card,
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
                      Icon(Icons.info_outline, size: 18, color: AppColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Le numéro Chifa vous permet de bénéficier de remboursements et d\'accéder à vos droits',
                          style: TextStyle(fontSize: 11, color: AppColors.info),
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
            Icon(Icons.credit_card, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Carte Chifa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
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
                Icon(Icons.info_outline, size: 14, color: AppColors.info),
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
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
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
              icon: Icons.email_rounded,
              label: 'Email',
              child: CustomTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'email@exemple.com',
                prefixIcon: Icons.email_outlined,
                enabled: false,
                readOnly: true,
              ),
            ),
            _FieldRow(
              icon: Icons.person_rounded,
              label: 'Nom complet',
              child: CustomTextField(
                controller: controller.fullNameController,
                label: 'Nom complet',
                hint: 'Votre nom complet',
                prefixIcon: Icons.person_outline,
                enabled: isEditing,
                readOnly: !isEditing,
              ),
            ),
            _FieldRow(
              icon: Icons.phone_rounded,
              label: 'Téléphone',
              child: CustomTextField(
                controller: controller.phoneController,
                label: 'Téléphone',
                hint: '0550 12 34 56',
                prefixIcon: Icons.phone_outlined,
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
  // SETTINGS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSettingsCard() {
    return _Card(
      title: 'Paramètres',
      child: Column(
        children: [
          Obx(() => _SwitchRow(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Recevoir des alertes et rappels',
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              )),
          const Divider(height: 1, color: AppColors.divider),
          Obx(() => _SwitchRow(
                icon: Icons.dark_mode_rounded,
                title: 'Mode sombre',
                subtitle: 'Activer le thème sombre',
                value: controller.darkModeEnabled.value,
                onChanged: controller.toggleDarkMode,
              )),
          const Divider(height: 1, color: AppColors.divider),
          Obx(() => _TileRow(
                icon: Icons.language_rounded,
                title: 'Langue',
                subtitle: controller.language.value,
                onTap: _showLanguageDialog,
              )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABOUT CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAboutCard() {
    return _Card(
      title: 'À propos',
      child: Column(
        children: [
          _TileRow(
            icon: Icons.description_rounded,
            title: "Conditions d'utilisation",
            onTap: () => Get.snackbar('Info', 'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _TileRow(
            icon: Icons.privacy_tip_rounded,
            title: 'Politique de confidentialité',
            onTap: () => Get.snackbar('Info', 'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _TileRow(
            icon: Icons.help_rounded,
            title: "Centre d'aide",
            onTap: () => Get.snackbar('Info', 'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT BUTTON
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: controller.showLogoutConfirmation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.error.withOpacity(0.5), width: 1.5),
          boxShadow: AppColors.shadowSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            const Text('Se déconnecter',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error)),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choisir la langue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français'),
            _buildLanguageOption('العربية'),
            _buildLanguageOption('English'),
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
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return Obx(() => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(language, style: const TextStyle(fontSize: 15)),
          leading: Radio<String>(
            value: language,
            groupValue: controller.language.value,
            onChanged: (value) {
              if (value != null) {
                controller.changeLanguage(value);
                Get.back();
              }
            },
            activeColor: AppColors.primary,
          ),
        ));
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
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool isVerified;
  final VoidCallback onTap;
  const _ChifaTile({
    required this.icon,
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
                color:
                    isVerified ? AppColors.successLight : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isVerified ? AppColors.success : AppColors.primary,
                  size: 22),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified,
                            size: 14, color: AppColors.success),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isVerified
                              ? AppColors.textPrimary
                              : AppColors.info)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon,
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
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _FieldRow(
      {required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: child,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _TileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _TileRow(
      {required this.icon,
      required this.title,
      this.subtitle,
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
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
          Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: isError ? AppColors.error : AppColors.success,
              size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    fontSize: 13,
                    color:
                        isError ? AppColors.errorDark : AppColors.successDark)),
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
