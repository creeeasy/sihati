import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:sihati_mobile/core/widgets/custom_text_field.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditing.value ? Icons.close : Icons.edit,
              ),
              onPressed: controller.toggleEditMode,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshUserData,
        color: AppColors.primary,
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
            return const Center(
              child: Text('Utilisateur non trouvé'),
            );
          }
          return _buildContent();
        }),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Profile header with avatar
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // Profile form
          _buildProfileForm(),

          const SizedBox(height: 24),

          // Settings
          _buildSettingsSection(),

          const SizedBox(height: 24),

          // About section
          _buildAboutSection(),

          const SizedBox(height: 24),

          // Logout button
          _buildLogoutButton(),

          const SizedBox(height: 16),

          // Version info
          Text(
            'Version 1.0.0',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final user = controller.user.value!;

      return Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                controller.getUserInitials(),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // User name and role
          Text(
            user.fullName,
            style: AppTextStyles.h4,
          ),

          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.getUserRole(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileForm() {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: AppTextStyles.subtitle1,
            ),

            const SizedBox(height: 16),

            // Email (read-only)
            CustomTextField(
              controller: controller.emailController,
              label: 'Email',
              hint: 'email@exemple.com',
              prefixIcon: Icons.email_outlined,
              enabled: false,
              readOnly: true,
            ),

            const SizedBox(height: 12),

            // Full name
            CustomTextField(
              controller: controller.fullNameController,
              label: 'Nom complet',
              hint: 'Votre nom complet',
              prefixIcon: Icons.person_outline,
              enabled: isEditing,
              readOnly: !isEditing,
            ),

            const SizedBox(height: 12),

            // Phone number
            CustomTextField(
              controller: controller.phoneController,
              label: 'Téléphone',
              hint: '0550 12 34 56',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              enabled: isEditing,
              readOnly: !isEditing,
            ),

            if (isEditing) ...[
              const SizedBox(height: 16),

              // Error/Success messages
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.successMessage.value.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.successMessage.value,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              }),

              const SizedBox(height: 16),

              // Save button
              CustomButton(
                text: 'Enregistrer les modifications',
                onPressed: controller.updateProfile,
                isLoading: controller.isLoading.value,
                icon: Icons.save,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres',
            style: AppTextStyles.subtitle1,
          ),

          const SizedBox(height: 16),

          // Notifications
          Obx(
            () => SwitchListTile(
              title: const Text(
                'Notifications',
                style: AppTextStyles.bodyMedium,
              ),
              subtitle: const Text(
                'Recevoir des alertes et rappels',
                style: AppTextStyles.caption,
              ),
              value: controller.notificationsEnabled.value,
              onChanged: controller.toggleNotifications,
              activeColor: AppColors.primary,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const Divider(),

          // Dark mode
          Obx(
            () => SwitchListTile(
              title: const Text(
                'Mode sombre',
                style: AppTextStyles.bodyMedium,
              ),
              subtitle: const Text(
                'Activer le thème sombre',
                style: AppTextStyles.caption,
              ),
              value: controller.darkModeEnabled.value,
              onChanged: controller.toggleDarkMode,
              activeColor: AppColors.primary,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dark_mode_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const Divider(),

          // Language
          ListTile(
            title: const Text(
              'Langue',
              style: AppTextStyles.bodyMedium,
            ),
            subtitle: Obx(
              () => Text(
                controller.language.value,
                style: AppTextStyles.caption,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language_outlined,
                color: AppColors.primary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À propos',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text(
              'Conditions d\'utilisation',
              style: AppTextStyles.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.snackbar(
                'Info',
                'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          ListTile(
            title: const Text(
              'Politique de confidentialité',
              style: AppTextStyles.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.snackbar(
                'Info',
                'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          ListTile(
            title: const Text(
              'Centre d\'aide',
              style: AppTextStyles.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.snackbar(
                'Info',
                'Fonctionnalité à implémenter',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return CustomButton(
      text: 'Se déconnecter',
      onPressed: controller.showLogoutConfirmation,
      isOutlined: true,
      backgroundColor: AppColors.error,
      textColor: AppColors.error,
      icon: Icons.logout,
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: Obx(
                () => Radio<String>(
                  value: 'Français',
                  groupValue: controller.language.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeLanguage(value);
                      Get.back();
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ),
            ListTile(
              title: const Text('العربية'),
              leading: Obx(
                () => Radio<String>(
                  value: 'العربية',
                  groupValue: controller.language.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeLanguage(value);
                      Get.back();
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Obx(
                () => Radio<String>(
                  value: 'English',
                  groupValue: controller.language.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeLanguage(value);
                      Get.back();
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
