import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

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
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in colored circle
            Container(
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                size: 64,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            // Main message
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Submessage
            if (submessage != null) ...[
              SizedBox(height: AppSpacing.sm + 4),
              Text(
                submessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button or retry
            if (onRetry != null || action != null) ...[
              SizedBox(height: AppSpacing.xl),
              if (action != null)
                action!
              else if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded),
                  label: Text(retryText ?? 'Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
