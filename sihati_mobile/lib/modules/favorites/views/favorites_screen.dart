import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesService = Get.find<FavoritesService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes favoris'),
          bottom: TabBar(
            tabs: [
              // Pharmacies tab with count badge
              Obx(() => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_pharmacy),
                        const SizedBox(width: 8),
                        const Text('Pharmacies'),
                        if (favoritesService.pharmacyCount > 0) ...[
                          const SizedBox(width: 6),
                          _CountBadge(count: favoritesService.pharmacyCount),
                        ],
                      ],
                    ),
                  )),

              // Doctors tab with count badge
              Obx(() => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.medical_services),
                        const SizedBox(width: 8),
                        const Text('Médecins'),
                        if (favoritesService.doctorCount > 0) ...[
                          const SizedBox(width: 6),
                          _CountBadge(count: favoritesService.doctorCount),
                        ],
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            // Clear all button
            Obx(() {
              if (favoritesService.totalCount == 0) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDialog(favoritesService),
                tooltip: 'Tout supprimer',
              );
            }),
          ],
        ),
        body: TabBarView(
          children: [
            // Pharmacies list
            _PharmaciesTab(favoritesService: favoritesService),

            // Doctors list
            _DoctorsTab(favoritesService: favoritesService),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(FavoritesService service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer tous les favoris ?'),
        content: const Text(
          'Cette action supprimera tous vos favoris (pharmacies et médecins).',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              service.clearAll();
              Get.back();
              Get.snackbar(
                'Supprimé',
                'Tous les favoris ont été supprimés',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Supprimer tout'),
          ),
        ],
      ),
    );
  }
}

// ==================== PHARMACIES TAB ====================

class _PharmaciesTab extends StatelessWidget {
  final FavoritesService favoritesService;

  const _PharmaciesTab({required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pharmacies = favoritesService.favoritePharmacies;

      if (pharmacies.isEmpty) {
        return EmptyState(
          icon: Icons.local_pharmacy_outlined,
          message: 'Aucune pharmacie favorite',
          submessage: 'Appuyez sur ❤️ dans une pharmacie pour l\'ajouter',
          action: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.PHARMACY_LIST),
            icon: const Icon(Icons.search),
            label: const Text('Trouver des pharmacies'),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = pharmacies[index];
          return _FavoritePharmacyCard(
            pharmacy: pharmacy,
            onTap: () =>
                Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/${pharmacy.id}'),
            onRemove: () =>
                favoritesService.removePharmacyFavorite(pharmacy.id),
          );
        },
      );
    });
  }
}

// ==================== DOCTORS TAB ====================

class _DoctorsTab extends StatelessWidget {
  final FavoritesService favoritesService;

  const _DoctorsTab({required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctors = favoritesService.favoriteDoctors;

      if (doctors.isEmpty) {
        return EmptyState(
          icon: Icons.medical_services_outlined,
          message: 'Aucun médecin favori',
          submessage: 'Appuyez sur ❤️ dans un médecin pour l\'ajouter',
          action: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.DOCTOR_LIST),
            icon: const Icon(Icons.search),
            label: const Text('Trouver des médecins'),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return _FavoriteDoctorCard(
            doctor: doctor,
            onTap: () => Get.toNamed('${AppRoutes.DOCTOR_DETAIL}/${doctor.id}'),
            onRemove: () => favoritesService.removeDoctorFavorite(doctor.id),
          );
        },
      );
    });
  }
}

// ==================== PHARMACY CARD ====================

class _FavoritePharmacyCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoritePharmacyCard({
    required this.pharmacy,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pharmacy.pharmacyName,
                            style: AppTextStyles.h6,
                          ),
                        ),
                        if (pharmacy.isOnDutyTonight)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.onDutyBadge,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'GARDE',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacy.fullAddress,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacy.phone,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove button
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.error,
                ),
                onPressed: onRemove,
                tooltip: 'Retirer des favoris',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DOCTOR CARD ====================

class _FavoriteDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteDoctorCard({
    required this.doctor,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with initials
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getInitials(doctor.doctorName),
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.doctorName,
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty.nameFr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctor.wilaya} · ${doctor.formattedFee}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    if (doctor.averageRating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.averageRating!.toStringAsFixed(1)} (${doctor.totalReviews ?? 0})',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.error,
                ),
                onPressed: onRemove,
                tooltip: 'Retirer des favoris',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.replaceAll('Dr.', '').trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

// ==================== COUNT BADGE ====================

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
