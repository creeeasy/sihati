import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../controllers/history_controller.dart';
import '../../../core/services/ai_service.dart';
import '../../../../app/routes/app_routes.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.history, size: 22, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm + 2),
            Text('Historique', style: AppTextStyles.h5),
          ],
        ),
        actions: [
          Obx(() {
            final hasFilter = controller.searchQuery.value.isNotEmpty ||
                controller.filterUrgency.value != null;
            if (!hasFilter) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.filter_alt_off, color: AppColors.textSecondary),
              tooltip: 'Effacer les filtres',
              onPressed: controller.clearFilters,
            );
          }),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textSecondary),
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm + 4,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: TextField(
        onChanged: controller.setSearch,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Rechercher dans vos conversations...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: AppSizing.iconSm,
            color: AppColors.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: AppSizing.borderRadiusFull,
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
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
      (null, 'Tous', AppColors.textSecondary),
      (UrgencyLevel.low, 'Léger', AppColors.success),
      (UrgencyLevel.medium, 'Modéré', AppColors.warning),
      (UrgencyLevel.high, 'Sérieux', AppColors.error),
      (UrgencyLevel.emergency, 'Urgence', AppColors.errorDark),
    ];

    return Container(
      height: 44,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontalMd,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
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
              labelStyle: AppTextStyles.caption.copyWith(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: selected ? color : AppColors.border,
              ),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
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
        color: AppColors.primary,
        child: ListView.separated(
          padding: AppSpacing.paddingMd,
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm + 2),
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
          color: AppColors.surface,
          borderRadius: AppSizing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _UrgencyBadge(urgency: item.urgency),
                const Spacer(),
                Text(
                  _formatDate(item.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm + 2),

            // User question
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizing.avatarXs,
                  height: AppSizing.avatarXs,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.userMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // AI reply preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizing.avatarXs,
                  height: AppSizing.avatarXs,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
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

            if (item.suggestedSpecialty != null ||
                item.medicationCount > 0) ...[
              SizedBox(height: AppSpacing.sm + 2),
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
                      color: AppColors.secondary,
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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizing.radiusXl),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: AppSpacing.sm + 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppSizing.borderRadiusXs,
              ),
            ),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  _UrgencyBadge(urgency: item.urgency),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.offNamed(
                        AppRoutes.AI_ASSISTANT,
                        arguments: {
                          'tag': item.hashCode.toString(),
                          'conversationId': item.id
                        },
                      );
                    },
                    icon:
                        Icon(Icons.chat_bubble_outline, size: AppSizing.iconSm),
                    label: Text('Continuer', style: AppTextStyles.button),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: AppSpacing.paddingMd,
                children: [
                  _DetailBubble(text: item.userMessage, isUser: true),
                  SizedBox(height: AppSpacing.sm + 4),
                  _DetailBubble(text: item.aiResponse, isUser: false),
                  if (item.suggestedSpecialty != null ||
                      item.medicationCount > 0) ...[
                    SizedBox(height: AppSpacing.md),
                    Divider(color: AppColors.divider),
                    SizedBox(height: AppSpacing.sm),
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
            color: isUser ? AppColors.primarySoft : null,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUser ? Icons.person : Icons.psychology,
            size: 15,
            color: isUser ? AppColors.primary : AppColors.white,
          ),
        ),
        SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: isUser ? AppColors.primarySoft : AppColors.background,
              borderRadius: AppSizing.borderRadiusMd,
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
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSizing.iconSm, color: AppColors.textTertiary),
          SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
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
      UrgencyLevel.emergency => ('Urgence', AppColors.error, Icons.emergency),
      UrgencyLevel.high => ('Sérieux', AppColors.error, Icons.warning_amber),
      UrgencyLevel.medium => ('Modéré', AppColors.warning, Icons.info_outline),
      UrgencyLevel.low => (
          'Léger',
          AppColors.success,
          Icons.check_circle_outline
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppSizing.borderRadiusFull,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
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
        borderRadius: AppSizing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.overline.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          Icon(
            Icons.chat_bubble_outline,
            size: AppSizing.iconXxl,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Aucune conversation',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Vos conversations avec l\'assistant apparaîtront ici.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
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
          Icon(
            Icons.search_off,
            size: AppSizing.iconXl,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.sm + 4),
          Text(
            'Aucun résultat',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
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
          Icon(Icons.error_outline,
              size: AppSizing.iconXl, color: AppColors.error),
          SizedBox(height: AppSpacing.sm + 4),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: AppSizing.iconSm),
            label: Text('Réessayer', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
