// lib/modules/medications/views/medication_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/core/models/medication_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/medication_detail_controller.dart';

class MedicationDetailScreen extends GetView<MedicationDetailController> {
  const MedicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _LoadingState(
              medicationName: controller.medication.value?.name ?? '');
        }
        if (controller.hasError.value || controller.medication.value == null) {
          return _ErrorState(onRetry: controller.retry);
        }
        return _Content(controller: controller);
      }),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String medicationName;
  const _LoadingState({required this.medicationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(AppIcons.arrowBack,
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          medicationName.isNotEmpty ? medicationName : 'Chargement...',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24),
            Text('Chargement des informations...',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(AppIcons.arrowBack,
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(AppIcons.errorIcon,
                    width: 64,
                    height: 64,
                    colorFilter: const ColorFilter.mode(
                        AppColors.error, BlendMode.srcIn)),
              ),
              SizedBox(height: AppSpacing.lg),
              const Text('Impossible de charger',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              SizedBox(height: AppSpacing.sm),
              const Text('Vérifiez votre connexion',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: SvgPicture.asset(AppIcons.history,
                    width: 20,
                    height: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final MedicationDetailController controller;
  const _Content({required this.controller});

  @override
  Widget build(BuildContext context) {
    final medication = controller.medication.value!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _AppBar(controller: controller),
        SliverPadding(
          padding: EdgeInsets.all(AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Description
              if (medication.description != null &&
                  medication.description!.isNotEmpty)
                _Section(
                  icon: AppIcons.prescription,
                  title: 'Description',
                  text: medication.description!,
                  color: AppColors.primary,
                ),

              // Indications
              if (medication.indications != null &&
                  medication.indications!.isNotEmpty)
                _Section(
                  icon: AppIcons.medication,
                  title: 'Indications',
                  text: medication.indications!,
                  color: AppColors.info,
                ),

              // Posology
              if (medication.posology != null &&
                  medication.posology!.isNotEmpty)
                _Section(
                  icon: AppIcons.calendar,
                  title: 'Posologie',
                  text: medication.posology!,
                  color: AppColors.secondary,
                ),

              // Quick info chips (Form, Dosage, DCI, Manufacturer)
              if (medication.form != null ||
                  medication.dosage != null ||
                  medication.dci != null ||
                  medication.manufacturer != null)
                _QuickInfoRow(medication: medication),

              // Prescription requirement
              _PrescriptionCard(
                  requiresPrescription: medication.requiresPrescription),

              // Contraindications
              if (medication.contraindications != null &&
                  medication.contraindications!.isNotEmpty)
                _Section(
                  icon: AppIcons.warning,
                  title: 'Contre-indications',
                  text: medication.contraindications!,
                  color: AppColors.error,
                ),

              // Side Effects
              if (medication.sideEffects != null &&
                  medication.sideEffects!.isNotEmpty)
                _Section(
                  icon: AppIcons.warning,
                  title: 'Effets secondaires',
                  text: medication.sideEffects!,
                  color: AppColors.warning,
                ),

              // Barcode
              if (medication.barcode != null && medication.barcode!.isNotEmpty)
                _BarcodeCard(barcode: medication.barcode!),

              // Drug Interaction Checker
              _DrugInteractionChecker(controller: controller),

              // Ask AI Section
              _AskAiSection(controller: controller),

              // Find Pharmacies CTA
              _FindPharmaciesCTA(medicationName: medication.name),

              // Disclaimer
              const _Disclaimer(),

              SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  final MedicationDetailController controller;
  const _AppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final medication = controller.medication.value!;

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: SvgPicture.asset(AppIcons.arrowBack,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        onPressed: () => Get.back(),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: SvgPicture.asset(AppIcons.reminder,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            onPressed: controller.setReminder,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: SvgPicture.asset(AppIcons.share,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            onPressed: controller.shareMedication,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient)),
            Positioned(
              bottom: -2,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(Get.width, 30),
                painter: _WavePainter(),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SvgPicture.asset(AppIcons.medication,
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn)),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(medication.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          if (medication.genericName != null)
                            Text(medication.genericName!,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13)),
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
}

class _PrescriptionCard extends StatelessWidget {
  final bool requiresPrescription;
  const _PrescriptionCard({required this.requiresPrescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: requiresPrescription
            ? AppColors.warningLight
            : AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: requiresPrescription
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            requiresPrescription ? AppIcons.prescription : AppIcons.verified,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              requiresPrescription ? AppColors.warning : AppColors.success,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              requiresPrescription
                  ? '🔴 Ordonnance médicale requise'
                  : '✅ Disponible sans ordonnance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: requiresPrescription
                    ? AppColors.warningDark
                    : AppColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugInteractionChecker extends StatelessWidget {
  final MedicationDetailController controller;
  const _DrugInteractionChecker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(AppIcons.warning,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        AppColors.error, BlendMode.srcIn)),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Vérifier les interactions',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.error)),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.interactionController,
            decoration: InputDecoration(
              hintText: 'Autre médicament...',
              hintStyle: TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary)),
              suffixIcon: IconButton(
                icon: SvgPicture.asset(AppIcons.search,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn)),
                onPressed: controller.checkInteraction,
              ),
            ),
            onSubmitted: (_) => controller.checkInteraction(),
          ),
          Obx(() {
            if (controller.isCheckingInteraction.value) {
              return Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }
            if (controller.interactionResult.value.isNotEmpty) {
              return Container(
                margin: EdgeInsets.only(top: AppSpacing.sm + 4),
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: controller.interactionResult.value.contains('⚠️') ||
                          controller.interactionResult.value.contains('🚫')
                      ? AppColors.warningLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.interactionResult.value.contains('⚠️') ||
                            controller.interactionResult.value.contains('🚫')
                        ? AppColors.warning.withOpacity(0.3)
                        : AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Text(controller.interactionResult.value,
                    style: TextStyle(fontSize: 13, height: 1.5)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _AskAiSection extends StatelessWidget {
  final MedicationDetailController controller;
  const _AskAiSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(AppIcons.aiPsychology,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                          AppColors.primary, BlendMode.srcIn)),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Posez une question',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                TextField(
                  controller: controller.questionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Ex: Puis-je prendre ce médicament avec du café?',
                    hintStyle:
                        TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                SizedBox(height: AppSpacing.sm + 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.askAiQuestion,
                    icon: Obx(() => controller.isAskingAi.value
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : SvgPicture.asset(AppIcons.send,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn))),
                    label: Obx(() => Text(
                        controller.isAskingAi.value ? 'Envoi...' : 'Envoyer')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Obx(() {
                  if (controller.aiAnswer.value.isNotEmpty) {
                    return Container(
                      margin: EdgeInsets.only(top: AppSpacing.md),
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(AppIcons.aiPsychology,
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                      AppColors.primary, BlendMode.srcIn)),
                              SizedBox(width: 8),
                              Text('Réponse de l\'IA',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 13)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(controller.aiAnswer.value,
                              style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FindPharmaciesCTA extends StatelessWidget {
  final String medicationName;
  const _FindPharmaciesCTA({required this.medicationName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(AppRoutes.MEDICATION_SEARCH,
              arguments: medicationName),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(AppIcons.pharmacy,
                      width: 26,
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn)),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trouver en pharmacie',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 2),
                      Text('Voir les pharmacies qui ont ce médicament',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12)),
                    ],
                  ),
                ),
                SvgPicture.asset(AppIcons.arrowForward,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.8), BlendMode.srcIn)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String icon;
  final String title;
  final String text;
  final Color color;
  const _Section(
      {required this.icon,
      required this.title,
      required this.text,
      required this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(icon,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
                SizedBox(width: AppSpacing.sm + 4),
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text(text,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppIcons.info,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn)),
          SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Text(
              'Ces informations sont à titre éducatif uniquement et ne remplacent pas l\'avis d\'un médecin ou pharmacien.',
              style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFF9FAFB)
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

// ═══════════════════════════════════════════════════════════════
// QUICK INFO ROW
// ═══════════════════════════════════════════════════════════════

class _QuickInfoRow extends StatelessWidget {
  final MedicationModel medication;
  const _QuickInfoRow({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (medication.dci != null && medication.dci!.isNotEmpty)
            _InfoChip(
                label: 'DCI', value: medication.dci!, color: AppColors.primary),
          if (medication.form != null && medication.form!.isNotEmpty)
            _InfoChip(
                label: 'Forme',
                value: medication.form!,
                color: AppColors.secondary),
          if (medication.dosage != null && medication.dosage!.isNotEmpty)
            _InfoChip(
                label: 'Dosage',
                value: medication.dosage!,
                color: AppColors.info),
          if (medication.manufacturer != null &&
              medication.manufacturer!.isNotEmpty)
            _InfoChip(
                label: 'Fabricant',
                value: medication.manufacturer!,
                color: AppColors.success),
          if (medication.category != null && medication.category!.isNotEmpty)
            _InfoChip(
                label: 'Catégorie',
                value: medication.category!,
                color: AppColors.warning),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BARCODE CARD
// ═══════════════════════════════════════════════════════════════

class _BarcodeCard extends StatelessWidget {
  final String barcode;
  const _BarcodeCard({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(AppIcons.qrCode,
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Code-barres',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(height: 2),
              Text(barcode,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}
