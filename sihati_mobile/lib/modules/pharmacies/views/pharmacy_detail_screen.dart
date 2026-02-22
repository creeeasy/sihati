import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/sihati_map.dart';
import '../controllers/pharmacy_detail_controller.dart';

class PharmacyDetailScreen extends GetView<PharmacyDetailController> {
  const PharmacyDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la pharmacie'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorDisplayWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadPharmacyDetails,
          );
        }

        final pharmacy = controller.pharmacy.value;
        if (pharmacy == null) {
          return const ErrorDisplayWidget(
            message: 'Pharmacie non trouvée',
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pharmacy.pharmacyName,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        if (pharmacy.isOnDutyTonight)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.nights_stay,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DE GARDE',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Appeler',
                        icon: Icons.phone,
                        onPressed: controller.callPharmacy,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (pharmacy.hasWhatsapp)
                      Expanded(
                        child: CustomButton(
                          text: 'WhatsApp',
                          icon: Icons.chat,
                          backgroundColor: const Color(0xFF25D366),
                          onPressed: controller.openWhatsApp,
                          height: 48,
                        ),
                      ),
                  ],
                ),
              ),

              // Map Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Text("Localisation sur la carte",
                            style: AppTextStyles.h6),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SihatiMap(
                      latitude: pharmacy.latitude,
                      longitude: pharmacy.longitude,
                      markerTitle: pharmacy.pharmacyName,
                      height: 220,
                      zoom: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Address Section
              _buildSection(
                title: 'Adresse',
                icon: Icons.location_on,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.fullAddress,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Itinéraire',
                      icon: Icons.directions,
                      isOutlined: true,
                      onPressed: controller.getDirections,
                      height: 40,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Contact Section
              _buildSection(
                title: 'Contact',
                icon: Icons.phone,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Téléphone',
                      pharmacy.phone,
                      Icons.phone,
                    ),
                    if (pharmacy.hasWhatsapp) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'WhatsApp',
                        pharmacy.whatsappNumber!,
                        Icons.chat,
                        color: const Color(0xFF25D366),
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1),

              // Opening Hours Section
              if (controller.openingHoursList.isNotEmpty) ...[
                _buildSection(
                  title: 'Horaires d\'ouverture',
                  icon: Icons.access_time,
                  child: Column(
                    children: controller.openingHoursList
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    entry.value,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: entry.value == 'Fermé'
                                          ? AppColors.error
                                          : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const Divider(height: 1),
              ],

              // Distance info
              if (pharmacy.distance != null)
                _buildSection(
                  title: 'Distance',
                  icon: Icons.directions_walk,
                  child: Text(
                    'À ${pharmacy.formattedDistance} de votre position',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.h6,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
