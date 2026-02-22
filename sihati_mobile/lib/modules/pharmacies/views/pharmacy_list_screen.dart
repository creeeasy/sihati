import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_widget.dart';
import '../controllers/pharmacy_list_controller.dart';
import 'widgets/pharmacy_card.dart';

class PharmacyListScreen extends GetView<PharmacyListController> {
  const PharmacyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              onChanged: controller.searchPharmacies,
              decoration: InputDecoration(
                hintText: 'Rechercher une pharmacie...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => controller.searchPharmacies(''),
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filter chips
          _buildFilterChips(),

          // Pharmacy list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(
                  message: 'Chargement des pharmacies...',
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return ErrorDisplayWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.refresh,
                );
              }

              final pharmacies = controller.filteredPharmacies;

              if (pharmacies.isEmpty) {
                return EmptyState(
                  message: 'Aucune pharmacie trouvée',
                  submessage: 'Essayez de modifier vos filtres',
                  icon: Icons.local_pharmacy,
                  onRetry: controller.clearFilters,
                  retryText: 'Réinitialiser les filtres',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacy = pharmacies[index];
                    return PharmacyCard(
                      pharmacy: pharmacy,
                      onTap: () => controller.goToPharmacyDetail(pharmacy.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Nearby filter
            Obx(() => FilterChip(
                  label: const Text('À proximité'),
                  selected: controller.showNearbyOnly.value,
                  onSelected: (_) => controller.toggleNearbyFilter(),
                  avatar: Icon(
                    Icons.location_on,
                    size: 18,
                    color: controller.showNearbyOnly.value
                        ? AppColors.white
                        : AppColors.primary,
                  ),
                )),

            const SizedBox(width: 8),

            // Wilaya filter
            Obx(() => FilterChip(
                  label: Text(controller.selectedWilaya.value ?? 'Wilaya'),
                  selected: controller.selectedWilaya.value != null,
                  onSelected: (_) => _showWilayaDialog(),
                  avatar: Icon(
                    Icons.place,
                    size: 18,
                    color: controller.selectedWilaya.value != null
                        ? AppColors.white
                        : AppColors.primary,
                  ),
                )),

            const SizedBox(width: 8),

            // Clear filters
            Obx(() {
              final hasFilters = controller.selectedWilaya.value != null ||
                  controller.showNearbyOnly.value;

              if (!hasFilters) return const SizedBox();

              return ActionChip(
                label: const Text('Effacer'),
                avatar: const Icon(Icons.clear, size: 18),
                onPressed: controller.clearFilters,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filtrer les pharmacies'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Pharmacies proches'),
              trailing: Obx(() => Switch(
                    value: controller.showNearbyOnly.value,
                    onChanged: (_) {
                      controller.toggleNearbyFilter();
                      Get.back();
                    },
                  )),
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Par wilaya'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.back();
                _showWilayaDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showWilayaDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sélectionner une wilaya'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.wilayas.length,
            itemBuilder: (context, index) {
              final wilaya = controller.wilayas[index];
              return ListTile(
                title: Text(wilaya),
                onTap: () {
                  controller.filterByWilaya(
                    wilaya == 'Tous' ? null : wilaya,
                  );
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
