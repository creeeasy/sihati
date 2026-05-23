// lib/modules/medical_record/views/medical_record_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/medical_record_controller.dart';
import 'widgets/bilan_tab.dart';
import 'widgets/ordonnances_tab.dart';
import 'widgets/historique_medicaments_tab.dart';
import 'widgets/consultations_tab.dart';
import 'widgets/documents_tab.dart';

class MedicalRecordScreen extends GetView<MedicalRecordController> {
  const MedicalRecordScreen({Key? key}) : super(key: key);

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
                const BoxDecoration(gradient: AppColors.primaryGradient),
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
            left: 24,
            right: 24,
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
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.medical_information_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mon Dossier Médical',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded,
                          size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Données sécurisées et confidentielles',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        onTap: controller.changeTab,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Bilan'),
          Tab(
              icon: Icon(Icons.description_outlined, size: 20),
              text: 'Ordonnances'),
          Tab(
              icon: Icon(Icons.medication_outlined, size: 20),
              text: 'Médicaments'),
          Tab(
              icon: Icon(Icons.calendar_today_outlined, size: 20),
              text: 'Consultations'),
          Tab(icon: Icon(Icons.folder_outlined, size: 20), text: 'Documents'),
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
