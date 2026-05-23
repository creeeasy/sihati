import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/error_widget.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import '../controllers/medication_search_controller.dart';
import 'widgets/medication_result_card.dart';

class MedicationSearchScreen extends GetView<MedicationSearchController> {
  const MedicationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildSearchSection()),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: controller.clearSearch,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
            ),
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 28),
                painter: WavePainter(),
              ),
            ),
            Positioned(
              top: 30,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medication_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recherche',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_pharmacy_rounded,
                                    color: Colors.white, size: 12),
                                SizedBox(width: 5),
                                Text(
                                  'Trouvez votre médicament',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Nom du médicament...',
                      hintStyle: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 14),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.search_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 14),
                    ),
                    onSubmitted: (_) => controller.searchMedication(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.searchMedication,
                    borderRadius: BorderRadius.circular(14),
                    child: Obx(() => controller.isLoading.value
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white)),
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 22)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 1.5),
            ),
            child: Obx(() => Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: controller.useLocation.value
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.near_me_rounded,
                        color: controller.useLocation.value
                            ? Colors.white
                            : AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Trier par distance',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                    Switch(
                      value: controller.useLocation.value,
                      onChanged: (_) => controller.toggleLocation(),
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                )),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildExampleChip('Doliprane'),
              _buildExampleChip('Nurofen'),
              _buildExampleChip('Aspirine'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return GestureDetector(
      onTap: () {
        controller.searchController.text = text;
        controller.searchMedication();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_rounded,
                size: 14, color: AppColors.warning),
            const SizedBox(width: 5),
            Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (!controller.hasSearched.value) return _buildInitialState();
      if (controller.isLoading.value) return const LoadingIndicator();
      if (controller.errorMessage.value.isNotEmpty) {
        return ErrorDisplayWidget(
          message: controller.errorMessage.value,
          onRetry: controller.searchMedication,
        );
      }
      if (controller.searchResults.isEmpty) {
        return EmptyState(
          message: 'Aucun médicament trouvé',
          submessage: 'Essayez un autre nom',
          icon: Icons.medication_rounded,
          onRetry: controller.searchMedication,
        );
      }
      return _buildResultsList();
    });
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_rounded,
                size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Recherchez un médicament',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Trouvez les pharmacies qui ont\nle médicament en stock',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.lightbulb_rounded,
                          color: AppColors.warning, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text(
                      'Exemples de recherche',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildExampleItem('Doliprane 1000mg'),
                _buildExampleItem('Nurofen 400mg'),
                _buildExampleItem('Aspirine'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String text) {
    return GestureDetector(
      onTap: () {
        controller.searchController.text = text;
        controller.searchMedication();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(7)),
              child: const Icon(Icons.search_rounded,
                  size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.success.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            '${controller.searchResults.length} résultat${controller.searchResults.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successDark),
                          )),
                      const Text(
                        'Pharmacies disponibles',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.successDark,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...controller.searchResults.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: MedicationResultCard(
                  result: result,
                  onPharmacyTap: controller.goToPharmacyDetail,
                  onDetailTap: () =>
                      controller.goToMedicationDetail(result.medication.id),
                ),
              )),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF9FAFB)
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
