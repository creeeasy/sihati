import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/history_controller.dart';
import '../controllers/ai_assistant_controller.dart';
import '../../../core/services/ai_service.dart';
import '../../../../app/routes/app_routes.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history, size: 22),
            SizedBox(width: 10),
            Text('Historique '),
          ],
        ),
        actions: [
          // Clear filters button — only shows when filters active
          Obx(() {
            final hasFilter = controller.searchQuery.value.isNotEmpty ||
                controller.filterUrgency.value != null;
            if (!hasFilter) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Effacer les filtres',
              onPressed: controller.clearFilters,
            );
          }),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: controller),
          _UrgencyFilterRow(controller: controller),
          Expanded(child: _Body(controller: controller)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final HistoryController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: TextField(
        onChanged: controller.setSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher dans vos conversations...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// URGENCY FILTER ROW
// ══════════════════════════════════════════════════════════════

class _UrgencyFilterRow extends StatelessWidget {
  final HistoryController controller;
  const _UrgencyFilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'Tous', Colors.grey),
      (UrgencyLevel.low, 'Léger', Colors.green),
      (UrgencyLevel.medium, 'Modéré', Colors.orange),
      (UrgencyLevel.high, 'Sérieux', Colors.deepOrange),
      (UrgencyLevel.emergency, 'Urgence', Colors.red),
    ];

    return Container(
      height: 44,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (level, label, color) = filters[i];
          return Obx(() {
            final selected = controller.filterUrgency.value == level;
            return FilterChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => controller.setUrgencyFilter(level),
              selectedColor: color.withOpacity(0.15),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: selected ? color : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          });
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BODY
// ══════════════════════════════════════════════════════════════

class _Body extends StatelessWidget {
  final HistoryController controller;
  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return _ErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.loadHistory,
        );
      }

      if (controller.conversations.isEmpty) {
        return const _EmptyState();
      }

      final items = controller.filtered;

      if (items.isEmpty) {
        return const _NoResultsState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadHistory,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _ConversationCard(item: items[i]),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════
// CONVERSATION CARD
// ══════════════════════════════════════════════════════════════

class _ConversationCard extends StatelessWidget {
  final ConversationHistoryItem item;
  const _ConversationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context, item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Top row: urgency badge + date
            Row(
              children: [
                _UrgencyBadge(urgency: item.urgency),
                const Spacer(),
                Text(
                  _formatDate(item.createdAt),
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // User question
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.userMessage,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // AI reply preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.aiResponse,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Tags row
            if (item.suggestedSpecialty != null ||
                item.medicationCount > 0) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  if (item.suggestedSpecialty != null)
                    _Tag(
                      icon: Icons.medical_services_outlined,
                      label: item.suggestedSpecialty!,
                      color: AppColors.primary,
                    ),
                  if (item.medicationCount > 0)
                    _Tag(
                      icon: Icons.medication,
                      label:
                          '${item.medicationCount} médicament${item.medicationCount > 1 ? 's' : ''}',
                      color: Colors.teal,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, ConversationHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(item: item),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';

    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// ══════════════════════════════════════════════════════════════
// DETAIL BOTTOM SHEET
// ══════════════════════════════════════════════════════════════

class _DetailSheet extends StatelessWidget {
  final ConversationHistoryItem item;
  const _DetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _UrgencyBadge(urgency: item.urgency),
                  const Spacer(),
                  // "Continuer cette conversation" button
                  TextButton.icon(
                    onPressed: () {
                      Get.back(); // close bottom sheet
                      Get.offNamed(
                        AppRoutes.AI_ASSISTANT,
                        arguments: {
                          'tag': item.hashCode.toString(),
                          'conversationId': item.id
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Continuer'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // User question
                  _DetailBubble(
                    text: item.userMessage,
                    isUser: true,
                  ),
                  const SizedBox(height: 12),
                  // AI response
                  _DetailBubble(
                    text: item.aiResponse,
                    isUser: false,
                  ),
                  // Metadata
                  if (item.suggestedSpecialty != null ||
                      item.medicationCount > 0) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (item.suggestedSpecialty != null)
                      _MetaRow(
                        icon: Icons.medical_services_outlined,
                        label: 'Spécialité conseillée',
                        value: item.suggestedSpecialty!,
                      ),
                    if (item.medicationCount > 0)
                      _MetaRow(
                        icon: Icons.medication,
                        label: 'Médicaments suggérés',
                        value:
                            '${item.medicationCount} médicament${item.medicationCount > 1 ? 's' : ''}',
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _DetailBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: isUser ? null : AppColors.primaryGradient,
            color: isUser ? AppColors.primary.withOpacity(0.15) : null,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUser ? Icons.person : Icons.psychology,
            size: 15,
            color: isUser ? AppColors.primary : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary.withOpacity(0.07)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              text,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text('$label: ',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
          Text(value,
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SMALL COMPONENTS
// ══════════════════════════════════════════════════════════════

class _UrgencyBadge extends StatelessWidget {
  final UrgencyLevel urgency;
  const _UrgencyBadge({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (urgency) {
      UrgencyLevel.emergency => ('Urgence', Colors.red, Icons.emergency),
      UrgencyLevel.high => ('Sérieux', Colors.deepOrange, Icons.warning_amber),
      UrgencyLevel.medium => ('Modéré', Colors.orange, Icons.info_outline),
      UrgencyLevel.low => ('Léger', Colors.green, Icons.check_circle_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Tag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// EMPTY / ERROR STATES
// ══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Aucune conversation',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
          const SizedBox(height: 8),
          Text('Vos conversations avec l\'assistant apparaîtront ici.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('Aucun résultat',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
