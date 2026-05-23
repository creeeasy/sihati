import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/appointment_model.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';

class MyAppointmentsController extends GetxController {
  final AppointmentRepository appointmentRepository;
  final StorageService storageService;

  MyAppointmentsController({
    required this.appointmentRepository,
    required this.storageService,
  });

  final appointments = <AppointmentModel>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      isLoading.value = true;

      final user = await storageService.getUser();
      if (user == null) return;

      final allAppointments =
          await appointmentRepository.getMyAppointments(user.id);
      appointments.value = allAppointments;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les rendez-vous',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<AppointmentModel> get upcomingAppointments {
    return appointments.where((a) => a.isUpcoming).toList();
  }

  List<AppointmentModel> get pastAppointments {
    return appointments.where((a) => a.isPast).toList();
  }

  Future<void> cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: Text(
          'Voulez-vous vraiment annuler votre rendez-vous du ${appointment.formattedDate} à ${appointment.appointmentTime} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler le RDV'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await appointmentRepository.cancelAppointment(appointment.id);
      await loadAppointments();

      Get.snackbar(
        'Succès',
        'Rendez-vous annulé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler le rendez-vous',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshAppointments() async {
    await loadAppointments();
  }
}
