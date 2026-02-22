import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';
import 'widgets/feature_card.dart';
import 'widgets/search_bar_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sihati',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  controller.userName.value.isNotEmpty
                      ? 'Bonjour, ${controller.userName.value}'
                      : 'Bienvenue',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: controller.goToProfile,
            tooltip: 'Profil',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              SearchBarWidget(
                onTap: controller.goToMedicationSearch,
              ),

              const SizedBox(height: 24),

              // Section Title
              Text(
                'Services disponibles',
                style: AppTextStyles.h5,
              ),

              const SizedBox(height: 16),

              // Feature Cards Grid - NOW WITH 6 CARDS INCLUDING AI!
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  // AI Assistant Card - NEW (Purple)
                  FeatureCard(
                    icon: Icons.auto_awesome,
                    title: 'Assistant Santé AI',
                    subtitle: 'Posez vos questions',
                    color: Colors.purple,
                    onTap: controller.goToAIAssistant, // <-- NEW METHOD
                  ),
                  // Pharmacies de garde (Green)
                  FeatureCard(
                    icon: Icons.local_pharmacy,
                    title: 'Pharmacies de garde',
                    subtitle: 'Ouvertes la nuit',
                    color: AppColors.accent,
                    onTap: controller.goToDutyPharmacies,
                  ),
                  // Trouver un médecin (Orange)
                  FeatureCard(
                    icon: Icons.medical_services,
                    title: 'Trouver un médecin',
                    subtitle: 'Par spécialité',
                    color: AppColors.secondary,
                    onTap: controller.goToDoctorList,
                  ),
                  // Pharmacies proches (Blue)
                  FeatureCard(
                    icon: Icons.location_on,
                    title: 'Pharmacies proches',
                    subtitle: 'Près de vous',
                    color: AppColors.primary,
                    onTap: controller.goToPharmacyList,
                  ),
                  // Chercher médicament (Cyan)
                  FeatureCard(
                    icon: Icons.search,
                    title: 'Chercher médicament',
                    subtitle: 'Disponibilité',
                    color: AppColors.info,
                    onTap: controller.goToMedicationSearch,
                  ),
                  // Favorites (Pink)
                  FeatureCard(
                    icon: Icons.favorite,
                    title: 'Mes Favoris',
                    subtitle: 'Sauvegardés',
                    color: Colors.pink,
                    onTap: controller.goToFavorites,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Information Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Besoin d\'aide ?',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trouvez rapidement des pharmacies et médecins près de chez vous',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.9),
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
        ),
      ),
    );
  }
}
