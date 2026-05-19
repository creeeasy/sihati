import 'package:flutter/material.dart';
import 'package:sihati_mobile/core/models/appointment_model.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(AppointmentModel.getStatusColor(appointment.status))
              .withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(AppointmentModel.getStatusColor(appointment.status))
                  .withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Color(
                      AppointmentModel.getStatusColor(appointment.status)),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${appointment.relativeDateText} • ${appointment.appointmentTime}',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: Color(
                        AppointmentModel.getStatusColor(appointment.status)),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                        AppointmentModel.getStatusColor(appointment.status)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppointmentModel.getStatusText(appointment.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Doctor info
          if (appointment.doctor != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      appointment.doctor!.doctorName
                          .substring(0, 2)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctor!.doctorName,
                          style: AppTextStyles.subtitle2,
                        ),
                        Text(
                          appointment.doctor!.specialty?.nameFr ?? 'Spécialiste',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (appointment.doctor!.clinicName.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  appointment.doctor!.clinicName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
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
            ),

          // Reason
          if (appointment.reason != null && appointment.reason!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.reason!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Actions
          if (onCancel != null || onReschedule != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                  if (onCancel != null && onReschedule != null)
                    const SizedBox(width: 8),
                  if (onReschedule != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onReschedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Reprogrammer'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
