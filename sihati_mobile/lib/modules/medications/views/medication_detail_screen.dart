import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';
import '../controllers/medication_detail_controller.dart';

class MedicationDetailScreen extends GetView<MedicationDetailController> {
  const MedicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _LoadingState(controller.medicationName);
        }
        if (controller.hasError.value || controller.info.value == null) {
          return _ErrorState(onRetry: controller.retry);
        }
        return _Content(
          name: controller.medicationName,
          info: controller.info.value!,
          controller: controller,
        );
      }),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String name;
  const _LoadingState(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A73E8)),
        title: Text(name,
            style: const TextStyle(
                color: Color(0xFF202124),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1A73E8)),
            const SizedBox(height: 24),
            Text('Chargement des informations...',
                style: TextStyle(fontSize: 15, color: Colors.grey[600])),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A73E8)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text('Impossible de charger les informations',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
  final String name;
  final MedicationInfoResponse info;
  final MedicationDetailController controller;

  const _Content({
    required this.name,
    required this.info,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _AppBar(name: name, info: info, controller: controller),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (info.reply.isNotEmpty) ...[
                _SummaryCard(text: info.reply),
                const SizedBox(height: 12),
              ],
              if (info.foundInDb && info.dbData != null) ...[
                _DbBadge(data: info.dbData!),
                const SizedBox(height: 12),
              ],
              _DrugInteractionChecker(controller: controller),
              const SizedBox(height: 12),
              _Section(
                icon: Icons.medication,
                title: 'Indications',
                text: info.usage,
                color: const Color(0xFF1A73E8),
              ),
              _Section(
                icon: Icons.block,
                title: 'Contre-indications',
                text: info.contraindications,
                color: const Color(0xFFE53935),
              ),
              _Section(
                icon: Icons.scale,
                title: 'Posologie',
                text: info.dosage,
                color: const Color(0xFF43A047),
              ),
              _Section(
                icon: Icons.warning_amber_rounded,
                title: 'Effets secondaires',
                text: info.sideEffects,
                color: const Color(0xFFFB8C00),
              ),
              _Section(
                icon: Icons.pregnant_woman,
                title: 'Grossesse & Allaitement',
                text: info.pregnancy,
                color: const Color(0xFF8E24AA),
              ),
              _Section(
                icon: Icons.link,
                title: 'Interactions médicamenteuses',
                text: info.interactions,
                color: const Color(0xFF00897B),
              ),
              if (info.warnings.isNotEmpty) ...[
                const SizedBox(height: 4),
                _WarningCard(text: info.warnings),
              ],
              const SizedBox(height: 16),
              _AskAiSection(controller: controller),
              const SizedBox(height: 16),
              _FindPharmaciesCTA(medicationName: name),
              const SizedBox(height: 16),
              const _Disclaimer(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  final String name;
  final MedicationInfoResponse info;
  final MedicationDetailController controller;

  const _AppBar({
    required this.name,
    required this.info,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: const Color(0xFF1A73E8),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() => IconButton(
              icon: Icon(
                controller.isFavorite.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: controller.toggleFavorite,
            )),
        IconButton(
          icon: const Icon(Icons.alarm, color: Colors.white),
          onPressed: controller.setReminder,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: controller.shareMedication,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medication,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        if (info.foundInDb &&
                            info.dbData?['genericName'] != null)
                          Text(info.dbData!['genericName'],
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE53935), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Vérifier les interactions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.interactionController,
            decoration: InputDecoration(
              hintText: 'Entrez un autre médicament...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A73E8)),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
                onPressed: controller.checkInteraction,
              ),
            ),
            onSubmitted: (_) => controller.checkInteraction(),
          ),
          Obx(() {
            if (controller.isCheckingInteraction.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1A73E8),
                  ),
                ),
              );
            }

            if (controller.interactionResult.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.interactionResult.value.contains('⚠️')
                      ? const Color(0xFFFFF8E1)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.interactionResult.value.contains('⚠️')
                        ? const Color(0xFFFB8C00)
                        : const Color(0xFF43A047),
                  ),
                ),
                child: Text(
                  controller.interactionResult.value,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A73E8).withOpacity(0.1),
                  const Color(0xFF0D47A1).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy,
                      color: Color(0xFF1A73E8), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Posez une question',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: controller.questionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Ex: Puis-je prendre ce médicament avec du café?',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A73E8)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.askAiQuestion,
                    icon: Obx(() => controller.isAskingAi.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 18)),
                    label: Obx(() => Text(
                        controller.isAskingAi.value ? 'Envoi...' : 'Envoyer')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  if (controller.aiAnswer.value.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1A73E8).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.smart_toy,
                                  color: Color(0xFF1A73E8), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Réponse de l\'IA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A73E8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.aiAnswer.value,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Color(0xFF1A237E),
                            ),
                          ),
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

class _SummaryCard extends StatelessWidget {
  final String text;
  const _SummaryCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A73E8).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1A73E8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A237E), height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _DbBadge extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DbBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF43A047).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Color(0xFF43A047), size: 18),
          const SizedBox(width: 8),
          const Text('Disponible dans notre base',
              style: TextStyle(
                  color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
          const Spacer(),
          if (data['price'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${data['price']} DA',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _Section({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF202124), height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String text;
  const _WarningCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFB8C00).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFB8C00), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Précautions importantes',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                        fontSize: 13)),
                const SizedBox(height: 6),
                Text(text,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF5D4037), height: 1.5)),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.back();
            Get.toNamed('/medication-search', arguments: medicationName);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_pharmacy,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                const Expanded(
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
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ces informations sont à titre éducatif uniquement et ne remplacent pas l\'avis d\'un médecin ou pharmacien.',
              style:
                  TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
