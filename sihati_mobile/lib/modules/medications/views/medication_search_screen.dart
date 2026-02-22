import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import '../controllers/medication_search_controller.dart';
import 'widgets/medication_result_card.dart';

class MedicationSearchScreen extends GetView<MedicationSearchController> {
  const MedicationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche de médicament'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: Obx(() {
              if (!controller.hasSearched.value) {
                return _buildInitialState();
              }
              if (controller.isLoading.value) {
                return const LoadingIndicator();
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
                  icon: Icons.medication_outlined,
                  onRetry: controller.searchMedication,
                );
              }
              return _buildResultsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Nom du médicament...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => controller.searchMedication(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Fixed CustomButton without isCompact parameter
              SizedBox(
                width: 120, // Fixed width instead of isCompact
                height: 50,
                child: CustomButton(
                  text: 'Rechercher',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.searchMedication,
                  isLoading: controller.isLoading.value,
                  // No isCompact parameter
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Text(
                    'Utiliser ma position pour trier par distance',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Switch(
                  value: controller.useLocation.value,
                  onChanged: (_) => controller.toggleLocation(),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Recherchez un médicament',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Trouvez les pharmacies qui ont le médicament en stock',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Exemples: Doliprane, Nurofen, Aspirine',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return RefreshIndicator(
      onRefresh: controller.searchMedication,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final result = controller.searchResults[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MedicationResultCard(
              result: result,
              onPharmacyTap: controller.goToPharmacyDetail,
            ),
          );
        },
      ),
    );
  }
}
