import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../controllers/ai_assistant_controller.dart';
import '../../../core/models/ai_models.dart';

class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';
    final controller = Get.find<AIAssistantController>(tag: tag);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _WaveHeader(controller: controller),
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "L'AI réfléchit...",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            if (controller.messages.length > 1) return const SizedBox.shrink();
            return _QuickSuggestions(controller: controller);
          }),
          const MessagesList(),
          _InputField(controller: controller),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WAVE HEADER  (matches Home / Pharmacy / MedicationDetail pattern)
// ═══════════════════════════════════════════════════════════════

class _WaveHeader extends StatelessWidget {
  final AIAssistantController controller;
  const _WaveHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Primary gradient background
        Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            children: [
              // Status bar spacer
              const SizedBox(height: 44),
              // Main header row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 18),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // AI avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assistant Santé AI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Propulsé par Gemini',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    _HeaderIconButton(
                      icon: Icons.delete_outline_rounded,
                      onPressed: controller.clearChat,
                      tooltip: 'Effacer',
                    ),
                    const SizedBox(width: 6),
                    _HeaderIconButton(
                      icon: Icons.history_rounded,
                      onPressed: () => Get.toNamed(AppRoutes.HISTORY),
                      tooltip: 'Historique',
                    ),
                  ],
                ),
              ),
              // Online status pill
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppSpacing.md, bottom: AppSpacing.md),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulseDot(),
                        const SizedBox(width: 6),
                        const Text(
                          'En ligne · Répond en quelques secondes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Wave spacer
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Decorative circles (wrapped with IgnorePointer so they don't block taps)
        Positioned(
          top: 44,
          right: -15,
          child: IgnorePointer(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
              ),
            ),
          ),
        ),
        Positioned(
          top: 84,
          left: 20,
          child: IgnorePointer(
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 14,
          right: 70,
          child: IgnorePointer(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
        ),
        // Wave at bottom
        Positioned(
          bottom: -1,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(Get.width, 28),
            painter: WavePainter(),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 17),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

/// Animated pulsing green dot — indicates "online"
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _anim = Tween(begin: 1.0, end: 0.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF64FFDA), // secondaryLight — teal
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MESSAGES LIST
// ═══════════════════════════════════════════════════════════════

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';
    final controller = Get.find<AIAssistantController>(tag: tag);
    return Expanded(
      child: Obx(
        () => ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) => _MessageBubble(
            message: controller.messages[index],
            onMedicationTap: controller.searchMedication,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String) onMedicationTap;

  const _MessageBubble({
    required this.message,
    required this.onMedicationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final ai = message.aiResponse;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Urgency banner above the bubble (AI only)
          if (!isUser &&
              ai != null &&
              (ai.urgency == UrgencyLevel.emergency ||
                  ai.urgency == UrgencyLevel.high))
            _UrgencyBanner(urgency: ai.urgency),

          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _Avatar(isUser: false),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Main text bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        border:
                            isUser ? null : Border.all(color: AppColors.border),
                        boxShadow: isUser ? null : AppColors.shadowSm,
                      ),
                      child: SelectableText(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Specialty chip
                    if (!isUser && ai?.suggestedSpecialty != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _SpecialtyChip(specialty: ai!.suggestedSpecialty!),
                    ],

                    // Medication suggestion cards
                    if (!isUser &&
                        ai?.medicationSuggestions.isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _MedicationList(
                        medications: ai!.medicationSuggestions,
                        onTap: onMedicationTap,
                      ),
                    ],

                    const SizedBox(height: 4),
                    Text(
                      _fmt(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: AppSpacing.sm),
                _Avatar(isUser: true),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════════
// URGENCY BANNER
// ═══════════════════════════════════════════════════════════════

class _UrgencyBanner extends StatelessWidget {
  final UrgencyLevel urgency;
  const _UrgencyBanner({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final isEmergency = urgency == UrgencyLevel.emergency;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isEmergency ? AppColors.errorLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEmergency
              ? AppColors.error.withOpacity(0.5)
              : AppColors.warning.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmergency ? Icons.emergency_rounded : Icons.warning_amber_rounded,
            color: isEmergency ? AppColors.error : AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              isEmergency
                  ? '🚨 URGENCE — Appelez le 14 (SAMU) immédiatement'
                  : '⚠️ Symptômes sérieux — Consultez un médecin rapidement',
              style: TextStyle(
                fontSize: 11,
                color:
                    isEmergency ? AppColors.errorDark : AppColors.warningDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SPECIALTY CHIP  — primary blue pill
// ═══════════════════════════════════════════════════════════════

class _SpecialtyChip extends StatelessWidget {
  final String specialty;
  const _SpecialtyChip({required this.specialty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medical_services_outlined,
              size: 13, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Consulter: $specialty',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEDICATION LIST
// ═══════════════════════════════════════════════════════════════

class _MedicationList extends StatelessWidget {
  final List<AIMedicationResult> medications;
  final void Function(String) onTap;

  const _MedicationList({required this.medications, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Médicaments suggérés :',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ...medications.map((med) => _MedicationCard(med: med, onTap: onTap)),
      ],
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final AIMedicationResult med;
  final void Function(String) onTap;

  const _MedicationCard({required this.med, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inStockPharmacies =
        med.availableInPharmacies.where((p) => p.inStock).toList();
    final dutyPharmacy =
        inStockPharmacies.where((p) => p.isOnDutyTonight).firstOrNull;

    return GestureDetector(
      onTap: () => onTap(med.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + prescription badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    med.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (med.requiresPrescription)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: AppColors.warning.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Ordonnance',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warningDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // Generic name / category
            if (med.genericName != null || med.category != null) ...[
              const SizedBox(height: 4),
              Text(
                [med.genericName, med.category].whereType<String>().join(' • '),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Availability row
            if (!med.foundInDb)
              _AvailRow(
                icon: Icons.info_outline_rounded,
                color: AppColors.textTertiary,
                text: 'Rechercher en pharmacie',
              )
            else if (inStockPharmacies.isEmpty)
              _AvailRow(
                icon: Icons.close_rounded,
                color: AppColors.error,
                text: 'Non disponible actuellement',
              )
            else ...[
              Row(
                children: [
                  _AvailRow(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    text:
                        'Disponible dans ${inStockPharmacies.length} pharmacie${inStockPharmacies.length > 1 ? 's' : ''}',
                  ),
                  if (med.basePrice != null) ...[
                    const Spacer(),
                    Text(
                      '${med.basePrice!.toStringAsFixed(0)} DA',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
              if (inStockPharmacies.isNotEmpty) ...[
                const SizedBox(height: 4),
                _PharmacyRow(pharmacy: inStockPharmacies.first),
              ],
              if (dutyPharmacy != null &&
                  dutyPharmacy.pharmacyId !=
                      inStockPharmacies.first.pharmacyId) ...[
                const SizedBox(height: 2),
                _PharmacyRow(pharmacy: dutyPharmacy, isDuty: true),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _AvailRow(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color == AppColors.success ? AppColors.successDark : color,
          ),
        ),
      ],
    );
  }
}

class _PharmacyRow extends StatelessWidget {
  final PharmacyStock pharmacy;
  final bool isDuty;

  const _PharmacyRow({required this.pharmacy, this.isDuty = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isDuty ? Icons.nightlight_round : Icons.store_rounded,
          size: 11,
          color: isDuty ? AppColors.info : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            isDuty
                ? '🌙 ${pharmacy.pharmacyName} (de garde)'
                : pharmacy.pharmacyName,
            style: TextStyle(
              fontSize: 11,
              color: isDuty ? AppColors.info : AppColors.textSecondary,
              fontWeight: isDuty ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (pharmacy.distance != null)
          Text(
            '${pharmacy.distance} km',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AVATAR
// ═══════════════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  final bool isUser;
  const _Avatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser ? null : AppColors.primaryGradient,
        color: isUser ? AppColors.primarySoft : null,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.psychology_rounded,
        size: 16,
        color: isUser ? AppColors.primary : Colors.white,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK SUGGESTIONS  — primary blue chips
// ═══════════════════════════════════════════════════════════════

class _QuickSuggestions extends StatelessWidget {
  final AIAssistantController controller;
  const _QuickSuggestions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions rapides :',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.quickSymptoms
                .map(
                  (s) => GestureDetector(
                    onTap: () => controller.sendQuickMessage(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.4)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INPUT FIELD
// ═══════════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {
  final AIAssistantController controller;
  const _InputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.shadowMd,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Décrivez vos symptômes...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Obx(
              () => GestureDetector(
                onTap:
                    controller.isLoading.value ? null : controller.sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: controller.isLoading.value
                        ? null
                        : AppColors.primaryGradient,
                    color: controller.isLoading.value
                        ? AppColors.textDisabled
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: controller.isLoading.value
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: controller.isLoading.value
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WAVE PAINTER  (shared across screens)
// ═══════════════════════════════════════════════════════════════

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF9FAFB)
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
