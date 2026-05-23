// lib/modules/appointments/views/book_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import 'package:sihati_mobile/core/widgets/custom_button.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/book_appointment_controller.dart';

class BookAppointmentScreen extends GetView<BookAppointmentController> {
  const BookAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre Rendez-vous'),
        elevation: 0,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildTimeSlots(),
                    const SizedBox(height: 24),
                    _buildReasonField(),
                    const SizedBox(height: 24),
                    _buildBookButton(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              doctor.doctorName.substring(0, 2).toUpperCase(),
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
                Text(doctor.doctorName, style: AppTextStyles.subtitle1),
                Text(
                  doctor.specialty?.nameFr ?? 'Spécialiste',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (doctor.consultationFee != null)
                  Text(
                    doctor.formattedFee,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
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
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              disabledDecoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ));
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🕐 Créneaux disponibles'),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingSlots.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.availableSlots.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Aucun créneau disponible ce jour',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableSlots.map((slot) {
              return Obx(() {
                final isSelected = controller.selectedTime.value == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (_) => controller.selectTimeSlot(slot),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
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
        const Text('📝 Motif (optionnel)'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ex: Consultation de suivi, Premier rendez-vous...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
