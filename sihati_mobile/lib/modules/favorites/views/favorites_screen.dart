import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
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
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildEpicHeader(favoritesService, innerBoxIsScrolled),
          ],
          body: TabBarView(
            children: [
              _PharmaciesTab(favoritesService: favoritesService),
              _DoctorsTab(favoritesService: favoritesService),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EPIC WAVE HEADER WITH TABS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEpicHeader(
      FavoritesService favoritesService, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          if (favoritesService.totalCount == 0) return const SizedBox();
          return Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
              onPressed: () => _showEpicDeleteDialog(favoritesService),
            ),
          );
        }),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Primary gradient
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),

            // Wave decoration
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 40),
                painter: WavePainter(),
              ),
            ),

            // Decorative circles
            Positioned(
              top: 60,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: 60,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md + 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes favoris',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 6),
                              Obx(() => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bookmark_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${favoritesService.totalCount} favori${favoritesService.totalCount > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: Container(
          color: AppColors.background,
          child: Obx(() => TabBar(
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    height: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_pharmacy_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Pharmacies'),
                        if (favoritesService.pharmacyCount > 0) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${favoritesService.pharmacyCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    height: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Médecins'),
                        if (favoritesService.doctorCount > 0) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${favoritesService.doctorCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  void _showEpicDeleteDialog(FavoritesService service) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withOpacity(0.2),
                      AppColors.error.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Tout supprimer ?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm + 4),
              Text(
                'Cette action supprimera tous vos favoris (pharmacies et médecins).',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        service.clearAll();
                        Get.back();
                        Get.snackbar(
                          'Supprimé',
                          'Tous les favoris ont été supprimés',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          margin: EdgeInsets.all(AppSpacing.md),
                          borderRadius: 12,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PHARMACIES TAB
// ═══════════════════════════════════════════════════════════════

class _PharmaciesTab extends StatelessWidget {
  final FavoritesService favoritesService;

  const _PharmaciesTab({required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pharmacies = favoritesService.favoritePharmacies;

      if (pharmacies.isEmpty) {
        return EmptyState(
          icon: Icons.local_pharmacy_rounded,
          message: 'Aucune pharmacie favorite',
          submessage: 'Commencez à sauvegarder vos pharmacies préférées',
          action: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.PHARMACY_LIST),
            icon: Icon(Icons.add_rounded, size: 20),
            label: Text('Découvrir des pharmacies'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md + 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        physics: const BouncingScrollPhysics(),
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = pharmacies[index];
          return _EpicPharmacyCard(
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

// ═══════════════════════════════════════════════════════════════
// DOCTORS TAB
// ═══════════════════════════════════════════════════════════════

class _DoctorsTab extends StatelessWidget {
  final FavoritesService favoritesService;

  const _DoctorsTab({required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctors = favoritesService.favoriteDoctors;

      if (doctors.isEmpty) {
        return EmptyState(
          icon: Icons.medical_services_rounded,
          message: 'Aucun médecin favori',
          submessage: 'Commencez à sauvegarder vos médecins préférés',
          action: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.DOCTOR_LIST),
            icon: Icon(Icons.add_rounded, size: 20),
            label: Text('Trouver des médecins'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md + 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        physics: const BouncingScrollPhysics(),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return _EpicDoctorCard(
            doctor: doctor,
            onTap: () => Get.toNamed('${AppRoutes.DOCTOR_DETAIL}/${doctor.id}'),
            onRemove: () => favoritesService.removeDoctorFavorite(doctor.id),
          );
        },
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// EPIC PHARMACY CARD
// ═══════════════════════════════════════════════════════════════

class _EpicPharmacyCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _EpicPharmacyCard({
    required this.pharmacy,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: pharmacy.isOnDutyTonight
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: pharmacy.isOnDutyTonight ? 2 : 1,
        ),
        boxShadow: pharmacy.isOnDutyTonight
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: pharmacy.isOnDutyTonight
                            ? AppColors.primary
                            : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.local_pharmacy_rounded,
                        color: pharmacy.isOnDutyTonight
                            ? Colors.white
                            : AppColors.primary,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pharmacy.pharmacyName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (pharmacy.isOnDutyTonight) ...[
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.nightlight_round,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'DE GARDE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                        onPressed: onRemove,
                      ),
                    ),
                  ],
                ),
                if (pharmacy.isOnDutyTonight)
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Text(
                        pharmacy.fullAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm + 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.phone_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm + 4),
                    Text(
                      pharmacy.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (pharmacy.hasWhatsapp) ...[
                      SizedBox(width: AppSpacing.sm + 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'WhatsApp',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EPIC DOCTOR CARD
// ═══════════════════════════════════════════════════════════════

class _EpicDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _EpicDoctorCard({
    required this.doctor,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md + 4),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.secondary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(doctor.doctorName),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.doctorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doctor.specialty?.nameFr ?? 'Spécialiste',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            doctor.wilaya,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.payments_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            doctor.formattedFee,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (doctor.averageRating != null) ...[
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${doctor.averageRating!.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${doctor.totalReviews ?? 0} avis)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    onPressed: onRemove,
                  ),
                ),
              ],
            ),
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

// ═══════════════════════════════════════════════════════════════
// WAVE PAINTER
// ═══════════════════════════════════════════════════════════════

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFF9FAFB)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.8,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
