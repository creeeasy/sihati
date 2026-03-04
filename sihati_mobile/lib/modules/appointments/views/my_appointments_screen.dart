import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/core/widgets/empty_state.dart';
import 'package:sihati_mobile/core/widgets/loading_indicator.dart';
import '../controllers/my_appointments_controller.dart';
import 'widgets/appointment_card.dart';

class MyAppointmentsScreen extends GetView<MyAppointmentsController> {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            _buildTabs(),
            Expanded(
              child: Obx(() {
                if (controller.selectedTab.value == 0) {
                  return _buildAppointmentsList(
                    controller.upcomingAppointments,
                    isUpcoming: true,
                  );
                } else {
                  return _buildAppointmentsList(
                    controller.pastAppointments,
                    isUpcoming: false,
                  );
                }
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabs() {
    return Container(
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
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  label: 'À venir (${controller.upcomingAppointments.length})',
                  isSelected: controller.selectedTab.value == 0,
                  onTap: () => controller.selectedTab.value = 0,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  label: 'Passés (${controller.pastAppointments.length})',
                  isSelected: controller.selectedTab.value == 1,
                  onTap: () => controller.selectedTab.value = 1,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List appointments, {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return EmptyState(
        message: isUpcoming
            ? 'Aucun rendez-vous à venir'
            : 'Aucun rendez-vous passé',
        icon: Icons.event_busy,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppointmentCard(
              appointment: appointments[index],
              onCancel: isUpcoming
                  ? () => controller.cancelAppointment(appointments[index])
                  : null,
              onReschedule: isUpcoming
                  ? () => controller.rescheduleAppointment(appointments[index])
                  : null,
            ),
          );
        },
      ),
    );
  }
}
