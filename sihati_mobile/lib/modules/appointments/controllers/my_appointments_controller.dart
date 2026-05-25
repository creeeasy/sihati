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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF59E0B),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Annuler le rendez-vous',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment annuler votre rendez-vous du ${appointment.formattedDate} à ${appointment.appointmentTime} ?',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF374151),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(result: false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Non',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Annuler le RDV',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
