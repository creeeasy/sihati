import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? submessage;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? action;

  const EmptyState({
    Key? key,
    required this.message,
    this.submessage,
    this.icon,
    this.onRetry,
    this.retryText,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: AppColors.textHint,
            ),

            const SizedBox(height: 24),

            // Main message
            Text(
              message,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Submessage
            if (submessage != null) ...[
              const SizedBox(height: 12),
              Text(
                submessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button or retry
            if (onRetry != null || action != null) ...[
              const SizedBox(height: 32),
              if (action != null)
                action!
              else if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryText ?? 'Réessayer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
