import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_widget.dart';
import '../controllers/duty_pharmacy_controller.dart';
import 'widgets/pharmacy_card.dart';

class DutyPharmacyScreen extends GetView<DutyPharmacyController> {
  const DutyPharmacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies de garde'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.place),
            onSelected: controller.filterByWilaya,
            itemBuilder: (context) => controller.wilayas
                .map((wilaya) => PopupMenuItem(
                      value: wilaya,
                      child: Text(wilaya),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.nights_stay,
                      color: AppColors.white,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pharmacies ouvertes cette nuit',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.currentDateTime,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Filter chip
          Obx(() {
            final wilaya = controller.selectedWilaya.value;
            if (wilaya == null || wilaya == 'Tous') {
              return const SizedBox();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.background,
              child: Row(
                children: [
                  Chip(
                    label: Text(wilaya),
                    deleteIcon: const Icon(Icons.clear, size: 18),
                    onDeleted: () => controller.filterByWilaya(null),
                  ),
                ],
              ),
            );
          }),

          // Pharmacy list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(
                  message: 'Chargement des pharmacies de garde...',
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.pharmacies.isEmpty) {
                return ErrorDisplayWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.refresh,
                );
              }

              final pharmacies = controller.pharmacies;

              if (pharmacies.isEmpty) {
                return EmptyState(
                  message: 'Aucune pharmacie de garde',
                  submessage:
                      'Aucune pharmacie n\'est de garde actuellement dans cette zone',
                  icon: Icons.local_pharmacy,
                  onRetry: controller.refresh,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: Column(
                  children: [
                    // Count banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: AppColors.success.withOpacity(0.1),
                      child: Text(
                        '${pharmacies.length} pharmacie(s) de garde disponible(s)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pharmacies.length,
                        itemBuilder: (context, index) {
                          final pharmacy = pharmacies[index];
                          return PharmacyCard(
                            pharmacy: pharmacy,
                            onTap: () =>
                                controller.goToPharmacyDetail(pharmacy.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
