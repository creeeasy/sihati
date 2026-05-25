// lib/modules/appointments/views/book_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/book_appointment_controller.dart';

class BookAppointmentScreen extends GetView<BookAppointmentController> {
  const BookAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prendre Rendez-vous', style: AppTextStyles.h5),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (controller.doctor == null) {
          return const Center(child: Text('Médecin non trouvé'));
        }

        return Column(
          children: [
            _buildDoctorHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildTimeSlots(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildReasonField(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildBookButton(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDoctorHeader() {
    final doctor = controller.doctor!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              doctor.doctorName.substring(0, 2).toUpperCase(),
              style: AppTextStyles.h5.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.doctorName, style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty?.nameFr ?? 'Spécialiste',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (doctor.consultationFee != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success50,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      doctor.formattedFee,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: AppColors.borderDefault),
            boxShadow: AppColors.shadowSm,
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: controller.focusedDay.value,
            selectedDayPredicate: (day) =>
                isSameDay(controller.selectedDate.value, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (controller.isDateSelectable(selectedDay)) {
                controller.selectDate(selectedDay);
              }
            },
            enabledDayPredicate: controller.isDateSelectable,
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.title,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              todayTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              disabledDecoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: AppTextStyles.bodyMedium,
              weekendTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ));
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppIcons.reminder, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            const SizedBox(width: AppSpacing.sm),
            Text('Créneaux disponibles', style: AppTextStyles.title),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(() {
          if (controller.isLoadingSlots.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (controller.availableSlots.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Center(
                child: Text(
                  'Aucun créneau disponible ce jour',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: controller.availableSlots.map((slot) {
              return Obx(() {
                final isSelected = controller.selectedTime.value == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (_) => controller.selectTimeSlot(slot),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.borderDefault,
                    ),
                  ),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              });
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppIcons.edit, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            const SizedBox(width: AppSpacing.sm),
            Text('Motif (optionnel)', style: AppTextStyles.title),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller.reasonController,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Ex: Consultation de suivi, Premier rendez-vous...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: AppSpacing.cardRadius,
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.cardRadius,
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.cardRadius,
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            text: controller.isLoading.value
                ? 'Confirmation...'
                : 'Confirmer le Rendez-vous',
            onPressed:
                controller.isLoading.value ? null : controller.bookAppointment,
            isLoading: controller.isLoading.value,
          ),
        ));
  }
}
