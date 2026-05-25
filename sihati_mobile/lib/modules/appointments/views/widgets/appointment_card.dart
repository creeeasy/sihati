import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/core/models/appointment_model.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        Color(AppointmentModel.getStatusColor(appointment.status));
    final statusText = AppointmentModel.getStatusText(appointment.status);
    final hasActions = onCancel != null || onReschedule != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        // Old code used only the left border
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status header ──────────────────────────────────
          _buildStatusHeader(statusColor, statusText),

          // ── Doctor info ────────────────────────────────────
          if (appointment.doctor != null) _buildDoctorInfo(statusColor),

          // ── Reason ─────────────────────────────────────────
          if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _buildReasonBlock(),
            ),
          ],

          // ── Actions ────────────────────────────────────────
          if (hasActions) _buildActions(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATUS HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusHeader(Color statusColor, String statusText) {
    return Container(
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppSpacing.radiusLg),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.calendar,
            width: AppSpacing.iconSizeMd,
            height: AppSpacing.iconSizeMd,
            colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${appointment.relativeDateText} • ${appointment.appointmentTime}',
              style: AppTextStyles.labelLarge.copyWith(color: statusColor),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.6),
              borderRadius: AppSpacing.chipRadius,
            ),
            child: Text(
              statusText,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DOCTOR INFO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDoctorInfo(Color statusColor) {
    final doctor = appointment.doctor!;

    return Padding(
      padding: AppSpacing.paddingCard,
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSpacing.avatarSizeMd / 2,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              doctor.doctorName.substring(0, 2).toUpperCase(),
              style:
                  AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.doctorName,
                  style: AppTextStyles.title,
                ),
                Text(
                  doctor.specialty?.nameFr ?? 'Spécialiste',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (doctor.clinicName.isNotEmpty)
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.location,
                        width: AppSpacing.iconSizeSm,
                        height: AppSpacing.iconSizeSm,
                        colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.clinicName,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // REASON BLOCK
  // ═══════════════════════════════════════════════════════════════

  Widget _buildReasonBlock() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppSpacing.inputRadius,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.medicalRecord,
            width: AppSpacing.iconSizeSm,
            height: AppSpacing.iconSizeSm,
            colorFilter: const ColorFilter.mode(
                AppColors.textSecondary, BlendMode.srcIn),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              appointment.reason!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActions() {
    return Padding(
      padding: AppSpacing.paddingCard,
      child: Row(
        children: [
          if (onCancel != null)
            Expanded(
              child: _PressableWidget(
                onTap: onCancel,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.error),
                    borderRadius: AppSpacing.buttonRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppIcons.close,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.error,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Annuler',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (onCancel != null && onReschedule != null)
            const SizedBox(width: AppSpacing.sm),
          if (onReschedule != null)
            Expanded(
              child: _PressableWidget(
                onTap: onReschedule,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppSpacing.buttonRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppIcons.calendar,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Reprogrammer',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRESS ANIMATION WRAPPER
// ═══════════════════════════════════════════════════════════════

class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableWidget({required this.child, this.onTap});

  @override
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
