import 'package:flutter/material.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/models/medication_search_result.dart';
import 'pharmacy_stock_card.dart';

class MedicationResultCard extends StatelessWidget {
  final MedicationSearchResult result;
  final Function(int) onPharmacyTap;

  const MedicationResultCard({
    super.key,
    required this.result,
    required this.onPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.medication.name,
                        style: AppTextStyles.h4,
                      ),
                      if (result.medication.genericName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          result.medication.genericName!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (result.medication.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.medication.category!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (result.medication.requiresPrescription)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ordonnance',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Availability count
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getAvailabilityMessage(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pharmacies list
            const Text(
              'Pharmacies disponibles:',
              style: AppTextStyles.subtitle2,
            ),

            const SizedBox(height: 8),

            ...result.pharmacies.take(3).map(
                  (pharmacyStock) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PharmacyStockCard(
                      pharmacyStock: pharmacyStock,
                      onTap: () => onPharmacyTap(pharmacyStock.pharmacy.id),
                    ),
                  ),
                ),

            if (result.pharmacies.length > 3) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => _showAllPharmacies(context),
                  child: Text(
                    '+ ${result.pharmacies.length - 3} autres pharmacies',
                    style: AppTextStyles.link,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getAvailabilityMessage() {
    final count = result.pharmacies.length;
    if (count == 0) return 'Non disponible';
    if (count == 1) return 'Disponible dans 1 pharmacie';
    return 'Disponible dans $count pharmacies';
  }

  void _showAllPharmacies(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              Text(
                result.medication.name,
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Text(
                'Toutes les pharmacies disponibles',
                style: AppTextStyles.subtitle2,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: result.pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacyStock = result.pharmacies[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PharmacyStockCard(
                        pharmacyStock: pharmacyStock,
                        onTap: () {
                          Navigator.pop(context);
                          onPharmacyTap(pharmacyStock.pharmacy.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
