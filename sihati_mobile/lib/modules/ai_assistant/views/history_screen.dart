import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../controllers/history_controller.dart';
import '../../../app/routes/app_routes.dart';

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
            if (controller.searchQuery.value.isEmpty)
              return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.close, color: AppColors.textSecondary),
              tooltip: 'Effacer',
              onPressed: controller.clearSearch,
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
          Expanded(child: _Body(controller: controller)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final HistoryController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm + 4, AppSpacing.md, AppSpacing.sm),
      color: AppColors.surface,
      child: TextField(
        onChanged: controller.setSearch,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Rechercher dans vos conversations...',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          prefixIcon: Icon(Icons.search,
              size: AppSizing.iconSm, color: AppColors.textTertiary),
          border: OutlineInputBorder(
            borderRadius: AppSizing.borderRadiusFull,
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final HistoryController controller;
  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.errorMessage.value != null) {
        return _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.loadHistory);
      }

      if (controller.conversations.isEmpty) return const _EmptyState();

      final items = controller.filtered;
      if (items.isEmpty) return const _NoResultsState();

      return RefreshIndicator(
        onRefresh: controller.loadHistory,
        color: AppColors.primary,
        child: ListView.separated(
          //padding: AppSpacing.paddingMd,
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm + 2),
          itemBuilder: (context, i) => _ConversationCard(item: items[i]),
        ),
      );
    });
  }
}

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
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSizing.avatarXs,
                        height: AppSizing.avatarXs,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person,
                            size: 14, color: AppColors.primary),
                      ),
                      SizedBox(width: AppSpacing.sm),
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
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _formatDate(item.createdAt),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
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
                  child:
                      Icon(Icons.psychology, size: 14, color: AppColors.white),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.aiResponse,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSizing.radiusXl)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: AppSpacing.sm + 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppSizing.borderRadiusXs),
            ),
            Container(
              //padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  Text('Conversation', style: AppTextStyles.h5),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.offNamed(AppRoutes.AI_ASSISTANT, arguments: {
                        'tag': item.hashCode.toString(),
                        'conversationId': item.id
                      });
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
                //padding: AppSpacing.paddingMd,
                children: [
                  _DetailBubble(text: item.userMessage, isUser: true),
                  SizedBox(height: AppSpacing.sm + 4),
                  _DetailBubble(text: item.aiResponse, isUser: false),
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
          child: Icon(isUser ? Icons.person : Icons.psychology,
              size: 15, color: isUser ? AppColors.primary : AppColors.white),
        ),
        SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Container(
            //padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: isUser ? AppColors.primarySoft : AppColors.background,
              borderRadius: AppSizing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(text,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: AppSizing.iconXxl, color: AppColors.textDisabled),
          SizedBox(height: AppSpacing.md),
          Text('Aucune conversation',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: AppSpacing.sm),
          Text('Vos conversations avec l\'assistant apparaîtront ici.',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
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
          Icon(Icons.search_off,
              size: AppSizing.iconXl, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.sm + 4),
          Text('Aucun résultat',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
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
          Text(message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: AppSizing.iconSm),
            label: Text('Réessayer', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
