import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../app/theme/app_colors.dart';
import '../services/favorites_service.dart';

/// Favorite button for Pharmacies
/// Drop into any screen - self-contained, handles its own state
class PharmacyFavoriteButton extends StatelessWidget {
  final PharmacyModel pharmacy;
  final double size;
  final bool showLabel;

  const PharmacyFavoriteButton({
    Key? key,
    required this.pharmacy,
    this.size = 24,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Get.find<FavoritesService>();

    return Obx(() {
      final isFavorite = service.isPharmacyFavorite(pharmacy.id);

      if (showLabel) {
        return TextButton.icon(
          onPressed: () => service.togglePharmacyFavorite(pharmacy),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.error : AppColors.textSecondary,
            size: size,
          ),
          label: Text(
            isFavorite ? 'Retiré des favoris' : 'Ajouter aux favoris',
            style: TextStyle(
              color: isFavorite ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        );
      }

      return IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.error : AppColors.textSecondary,
          size: size,
        ),
        onPressed: () => service.togglePharmacyFavorite(pharmacy),
        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
      );
    });
  }
}

/// Favorite button for Doctors
/// Drop into any screen - self-contained, handles its own state
class DoctorFavoriteButton extends StatelessWidget {
  final DoctorModel doctor;
  final double size;
  final bool showLabel;

  const DoctorFavoriteButton({
    Key? key,
    required this.doctor,
    this.size = 24,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Get.find<FavoritesService>();

    return Obx(() {
      final isFavorite = service.isDoctorFavorite(doctor.id);

      if (showLabel) {
        return TextButton.icon(
          onPressed: () => service.toggleDoctorFavorite(doctor),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.error : AppColors.textSecondary,
            size: size,
          ),
          label: Text(
            isFavorite ? 'Retiré des favoris' : 'Ajouter aux favoris',
            style: TextStyle(
              color: isFavorite ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        );
      }

      return IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.error : AppColors.textSecondary,
          size: size,
        ),
        onPressed: () => service.toggleDoctorFavorite(doctor),
        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
      );
    });
  }
}
