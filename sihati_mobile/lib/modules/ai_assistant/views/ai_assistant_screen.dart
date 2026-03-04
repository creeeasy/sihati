import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/ai_assistant_controller.dart';
import '../../../core/services/ai_service.dart';

class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';
    final controller = Get.find<AIAssistantController>(tag: tag);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.psychology, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistant Santé AI', style: TextStyle(fontSize: 16)),
                Text('Propulsé par Gemini',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearChat,
            tooltip: 'Effacer la conversation',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed(AppRoutes.HISTORY),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          const MessagesList(),

          // Loading indicator
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("L'AI réfléchit...", style: AppTextStyles.caption),
                ],
              ),
            );
          }),

          // Quick suggestions (first message only)
          Obx(() {
            if (controller.messages.length > 1) return const SizedBox.shrink();
            return _QuickSuggestions(controller: controller);
          }),

          // Input field
          _InputField(controller: controller),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ══════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Urgency banner (emergency / high only)
          if (!isUser &&
              ai != null &&
              (ai.urgency == UrgencyLevel.emergency ||
                  ai.urgency == UrgencyLevel.high))
            _UrgencyBanner(urgency: ai.urgency),

          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                _Avatar(isUser: false),
                const SizedBox(width: 8)
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Text bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isUser ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            isUser ? null : Border.all(color: AppColors.border),
                      ),
                      child: SelectableText(
                        message.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Specialty suggestion chip
                    if (!isUser && ai?.suggestedSpecialty != null) ...[
                      const SizedBox(height: 8),
                      _SpecialtyChip(specialty: ai!.suggestedSpecialty!),
                    ],

                    // Medication results with pharmacy stock
                    if (!isUser &&
                        ai?.medicationSuggestions.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      _MedicationList(
                        medications: ai!.medicationSuggestions,
                        onTap: onMedicationTap,
                      ),
                    ],

                    // Timestamp
                    const SizedBox(height: 4),
                    Text(
                      _fmt(message.timestamp),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              if (isUser) ...[const SizedBox(width: 8), _Avatar(isUser: true)],
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

// ══════════════════════════════════════════════════════════════
// URGENCY BANNER
// ══════════════════════════════════════════════════════════════

class _UrgencyBanner extends StatelessWidget {
  final UrgencyLevel urgency;
  const _UrgencyBanner({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final isEmergency = urgency == UrgencyLevel.emergency;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isEmergency ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEmergency ? Colors.red : Colors.orange,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmergency ? Icons.emergency : Icons.warning_amber,
            color: isEmergency ? Colors.red : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isEmergency
                ? '🚨 URGENCE — Appelez le 14 (SAMU) immédiatement'
                : '⚠️ Symptômes sérieux — Consultez un médecin rapidement',
            style: TextStyle(
              color: isEmergency ? Colors.red.shade800 : Colors.orange.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SPECIALTY CHIP
// ══════════════════════════════════════════════════════════════

class _SpecialtyChip extends StatelessWidget {
  final String specialty;
  const _SpecialtyChip({required this.specialty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medical_services_outlined,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Consulter: $specialty',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MEDICATION LIST
// ══════════════════════════════════════════════════════════════

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
          'Médicaments suggérés:',
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication name + prescription badge
            Row(
              children: [
                const Icon(Icons.medication,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    med.name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (med.requiresPrescription)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Ordonnance',
                      style: TextStyle(
                          fontSize: 10, color: Colors.orange.shade800),
                    ),
                  ),
              ],
            ),

            // Generic name + category
            if (med.genericName != null || med.category != null) ...[
              const SizedBox(height: 4),
              Text(
                [med.genericName, med.category].whereType<String>().join(' • '),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 8),

            // Stock status
            if (!med.foundInDb)
              // AI suggested but not in our database
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text('Rechercher en pharmacie',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint)),
                ],
              )
            else if (inStockPharmacies.isEmpty)
              Row(
                children: [
                  const Icon(Icons.close, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('Non disponible actuellement',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.red.shade700)),
                ],
              )
            else ...[
              // Available — show count + nearest
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Disponible dans ${inStockPharmacies.length} pharmacie${inStockPharmacies.length > 1 ? 's' : ''}',
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.green.shade700),
                  ),
                  if (med.basePrice != null) ...[
                    const Spacer(),
                    Text(
                      '${med.basePrice!.toStringAsFixed(0)} DA',
                      style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ],
              ),

              // Nearest pharmacy
              if (inStockPharmacies.isNotEmpty) ...[
                const SizedBox(height: 4),
                _PharmacyRow(pharmacy: inStockPharmacies.first),
              ],

              // On-duty pharmacy (if different from nearest)
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

class _PharmacyRow extends StatelessWidget {
  final PharmacyStock pharmacy;
  final bool isDuty;

  const _PharmacyRow({required this.pharmacy, this.isDuty = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isDuty ? Icons.nightlight_round : Icons.store,
          size: 12,
          color: isDuty ? Colors.blue : AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            pharmacy.pharmacyName,
            style: AppTextStyles.caption.copyWith(
              color: isDuty ? Colors.blue : AppColors.textSecondary,
              fontWeight: isDuty ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (pharmacy.distance != null)
          Text(
            '${pharmacy.distance} km',
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AVATAR
// ══════════════════════════════════════════════════════════════

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
        color: isUser ? AppColors.primary.withOpacity(0.2) : null,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        size: 18,
        color: isUser ? AppColors.primary : Colors.white,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// QUICK SUGGESTIONS
// ══════════════════════════════════════════════════════════════

class _QuickSuggestions extends StatelessWidget {
  final AIAssistantController controller;
  const _QuickSuggestions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suggestions rapides:', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.quickSymptoms
                .map((s) => ActionChip(
                      label: Text(s),
                      onPressed: () => controller.sendQuickMessage(s),
                      backgroundColor: Colors.white,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// INPUT FIELD
// ══════════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {
  final AIAssistantController controller;
  const _InputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.sendMessage(),
              decoration: InputDecoration(
                hintText: 'Décrivez vos symptômes...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => FloatingActionButton(
                mini: true,
                onPressed:
                    controller.isLoading.value ? null : controller.sendMessage,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
              )),
        ],
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';
    final controller = Get.find<AIAssistantController>(tag: tag);
    return Expanded(
      child: Obx(() => ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) => _MessageBubble(
              message: controller.messages[index],
              onMedicationTap: controller.searchMedication,
            ),
          )),
    );
  }
}
