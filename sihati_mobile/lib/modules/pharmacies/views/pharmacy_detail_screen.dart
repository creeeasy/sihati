import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/sihati_mapbox.dart';
import '../controllers/pharmacy_detail_controller.dart';

class PharmacyDetailScreen extends GetView<PharmacyDetailController> {
  const PharmacyDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: SihatiMapbox(
                    latitude: pharmacy.latitude,
                    longitude: pharmacy.longitude,
                    markerTitle: pharmacy.pharmacyName,
                    height: double.infinity,
                    zoom: 15,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: _buildDetailsSheet(pharmacy),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: _buildBackButton(),
            ),
            if (pharmacy.isOnDutyTonight)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 8,
                child: _buildOnDutyBadge(),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildOnDutyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.nights_stay,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            'DE GARDE',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSheet(pharmacy) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            Text(
              pharmacy.pharmacyName,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    pharmacy.fullAddress,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            if (pharmacy.distance != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_walk,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'À ${pharmacy.formattedDistance}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Appeler',
                    icon: Icons.phone,
                    onPressed: controller.callPharmacy,
                    height: 50,
                  ),
                ),
                if (pharmacy.hasWhatsapp) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'WhatsApp',
                      icon: Icons.chat,
                      backgroundColor: const Color(0xFF25D366),
                      onPressed: controller.openWhatsApp,
                      height: 50,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Obtenir l\'itinéraire',
              icon: Icons.directions,
              isOutlined: true,
              onPressed: controller.getDirections,
              height: 50,
            ),
            if (controller.openingHoursList.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Horaires d\'ouverture',
                    style: AppTextStyles.h6,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...controller.openingHoursList.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Contact',
                  style: AppTextStyles.h6,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              icon: Icons.phone,
              label: 'Téléphone',
              value: pharmacy.phone,
            ),
            if (pharmacy.hasWhatsapp) ...[
              const SizedBox(height: 12),
              _buildContactRow(
                icon: Icons.chat,
                label: 'WhatsApp',
                value: pharmacy.whatsappNumber!,
                color: const Color(0xFF25D366),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
