// lib/modules/appointments/controllers/book_appointment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class BookAppointmentController extends GetxController {
  final AppointmentRepository appointmentRepository;
  final StorageService storageService;

  BookAppointmentController({
    required this.appointmentRepository,
    required this.storageService,
  });

  DoctorModel? doctor;

  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<String>();
  final availableSlots = <String>[].obs;
  final isLoadingSlots = false.obs;
  final reasonController = TextEditingController();
  final focusedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is DoctorModel) {
      doctor = Get.arguments as DoctorModel;
    }

    if (doctor == null) {
      Get.back();
      Get.snackbar('Erreur', 'Médecin non trouvé',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final today = DateTime.now();
    selectedDate.value = today;
    focusedDay.value = today;
    loadAvailableSlots(today);
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  Future<void> loadAvailableSlots(DateTime date) async {
    try {
      isLoadingSlots.value = true;
      availableSlots.clear();
      selectedTime.value = null;

      final slots = await appointmentRepository.getAvailableSlots(
        doctorId: doctor!.id,
        date: date,
      );

      availableSlots.value = slots;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les créneaux disponibles',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    focusedDay.value = date;
    loadAvailableSlots(date);
  }

  void selectTimeSlot(String time) {
    selectedTime.value = time;
  }

  bool isDateSelectable(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate.isBefore(today)) return false;

    final maxDate = today.add(const Duration(days: 30));
    return checkDate.isBefore(maxDate) || checkDate.isAtSameMomentAs(maxDate);
  }

  Future<void> bookAppointment() async {
    if (selectedDate.value == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner une date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (selectedTime.value == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner un créneau horaire',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final user = await storageService.getUser();
      if (user == null) throw Exception('Utilisateur non connecté');

      final appointment = await appointmentRepository.bookAppointment(
        patientId: user.id,
        doctorId: doctor!.id,
        date: selectedDate.value!,
        time: selectedTime.value!,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      Get.back();

      Get.snackbar(
        'Succès',
        'Rendez-vous confirmé pour le ${appointment.formattedDate} à ${appointment.appointmentTime}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      Get.toNamed(AppRoutes.MY_APPOINTMENTS);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
