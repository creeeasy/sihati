import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import '../controllers/doctor_list_controller.dart';
import 'widgets/doctor_card.dart';

class DoctorListScreen extends GetView<DoctorListController> {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médecins'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredDoctors.isEmpty) {
                return const LoadingIndicator();
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return ErrorDisplayWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshData,
                );
              }
              if (controller.filteredDoctors.isEmpty) {
                return EmptyState(
                  message: 'Aucun médecin trouvé',
                  submessage:
                      'Essayez de modifier vos filtres ou d\'effectuer une nouvelle recherche',
                  icon: Icons.medical_services_outlined,
                  onRetry: controller.refreshData,
                  retryText: 'Actualiser',
                );
              }
              return _buildDoctorsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher un médecin...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: controller.searchDoctorsByName,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 50,
            child: CustomButton(
              text: '',
              onPressed: _showFilterBottomSheet,
              isOutlined: true,
              icon: Icons.tune,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(
      () {
        // Only show chips if there are active filters
        final hasActiveFilters = controller.selectedSpecialtyId.value != null ||
            (controller.selectedWilaya.value != null &&
                controller.selectedWilaya.value!.isNotEmpty) ||
            controller.useLocation.value ||
            controller.searchQuery.value.isNotEmpty;

        if (!hasActiveFilters) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (controller.selectedSpecialtyId.value != null)
                _buildFilterChip(
                  label: controller
                      .getSpecialtyName(controller.selectedSpecialtyId.value),
                  onDeleted: () => controller.filterBySpecialty(null),
                ),
              if (controller.selectedWilaya.value != null &&
                  controller.selectedWilaya.value!.isNotEmpty)
                _buildFilterChip(
                  label: controller.selectedWilaya.value!,
                  onDeleted: () => controller.filterByWilaya(null),
                ),
              if (controller.useLocation.value)
                _buildFilterChip(
                  label: 'À proximité',
                  onDeleted: () => controller.toggleNearbyFilter(),
                ),
              if (controller.searchQuery.value.isNotEmpty)
                _buildFilterChip(
                  label: '"${controller.searchQuery.value}"',
                  onDeleted: () => controller.searchDoctorsByName(''),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton(
                  onPressed: controller.clearFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Effacer tout'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onDeleted(),
        selected: true,
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        selectedColor: AppColors.primary.withOpacity(0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = controller.filteredDoctors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DoctorCard(
              doctor: doctor,
              onTap: () => controller.goToDoctorDetail(doctor.id),
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends GetView<DoctorListController> {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Filtres',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),

              // Filter summary
              Obx(
                () => Text(
                  controller.getFilterSummary(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Sort options
                    _buildSection(
                      title: 'Trier par',
                      child: Obx(
                        () => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSortChip('Proximité', 'distance'),
                            _buildSortChip('Note', 'rating'),
                            _buildSortChip('Prix', 'fee'),
                            _buildSortChip('Expérience', 'experience'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Specialty filter
                    _buildSection(
                      title: 'Spécialité',
                      child: Obx(
                        () {
                          // Show loading if specialties not loaded
                          if (controller.specialties.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSpecialtyChip(
                                label: 'Toutes',
                                isSelected:
                                    controller.selectedSpecialtyId.value ==
                                        null,
                                onTap: () => controller.filterBySpecialty(null),
                              ),
                              ...controller.specialties.map(
                                (specialty) => _buildSpecialtyChip(
                                  label: specialty.nameFr,
                                  isSelected:
                                      controller.selectedSpecialtyId.value ==
                                          specialty.id,
                                  onTap: () => controller
                                      .filterBySpecialty(specialty.id),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Wilaya filter
                    _buildSection(
                      title: 'Wilaya',
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Obx(
                          () => ListView.builder(
                            itemCount: controller.algerianWilayas.length,
                            itemBuilder: (context, index) {
                              final wilaya = controller.algerianWilayas[index];
                              return RadioListTile<String>(
                                title: Text(
                                  wilaya,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                value: wilaya,
                                groupValue: controller.selectedWilaya.value,
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.filterByWilaya(value);
                                    Navigator.pop(context);
                                  }
                                },
                                activeColor: AppColors.primary,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                dense: true,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nearby filter
                    _buildSection(
                      title: 'Localisation',
                      child: Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'À proximité',
                              style: AppTextStyles.subtitle2,
                            ),
                            subtitle: Text(
                              'Afficher les médecins proches de votre position',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            value: controller.useLocation.value,
                            onChanged: (_) {
                              controller.toggleNearbyFilter();
                              Navigator.pop(context);
                            },
                            activeColor: AppColors.primary,
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Apply button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  text: 'Voir les résultats',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    return Obx(
      () => FilterChip(
        label: Text(label),
        selected: controller.sortBy.value == value,
        onSelected: (_) {
          controller.changeSortBy(value);
          Navigator.pop(Get.context!);
        },
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: controller.sortBy.value == value
              ? Colors.white
              : AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}
