import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../controllers/medical_record_controller.dart';
import 'widgets/bilan_tab.dart';
import 'widgets/ordonnances_tab.dart';
import 'widgets/historique_medicaments_tab.dart';
import 'widgets/consultations_tab.dart';
import 'widgets/documents_tab.dart';

class MedicalRecordScreen extends GetView<MedicalRecordController> {
  const MedicalRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 5,
        initialIndex: controller.tabIndex.value,
        child: SafeArea(
          child: Column(
            children: [
              _buildWaveHeader(),
              _buildTabs(),
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.tabIndex.value,
                      children: const [
                        BilanTab(),
                        OrdonnancesTabContent(),
                        HistoriqueMedicamentsTabContent(),
                        ConsultationsTab(),
                        DocumentsTab(),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveHeader() {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Container(
            decoration:
                const BoxDecoration(gradient: AppColors.homeHeaderGradient),
          ),
          Positioned(
            top: -30,
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
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(Get.width, 40),
              painter: _WavePainter(color: AppColors.background),
            ),
          ),
          Positioned(
            bottom: 36,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: controller.goBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(AppIcons.arrowBack,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(AppIcons.medicalRecord,
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mon Dossier Médical',
                  style:
                      AppTextStyles.displayMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AppIcons.verified,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn)),
                      const SizedBox(width: 6),
                      Text(
                        'Données sécurisées et confidentielles',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: TabBar(
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle:
            AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        onTap: controller.changeTab,
        tabs: [
          Tab(
              icon: SvgPicture.asset(AppIcons.medicalRecord,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                      controller.tabIndex.value == 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      BlendMode.srcIn)),
              text: 'Bilan'),
          Tab(
              icon: SvgPicture.asset(AppIcons.prescription,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                      controller.tabIndex.value == 1
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      BlendMode.srcIn)),
              text: 'Ordonnances'),
          Tab(
              icon: SvgPicture.asset(AppIcons.medication,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                      controller.tabIndex.value == 2
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      BlendMode.srcIn)),
              text: 'Médicaments'),
          Tab(
              icon: SvgPicture.asset(AppIcons.consultation,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                      controller.tabIndex.value == 3
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      BlendMode.srcIn)),
              text: 'Consultations'),
          Tab(
              icon: SvgPicture.asset(AppIcons.medicalRecord,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                      controller.tabIndex.value == 4
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      BlendMode.srcIn)),
              text: 'Documents'),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2,
          size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.8, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
