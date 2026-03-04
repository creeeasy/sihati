import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';

class BookAppointmentController extends GetxController {
  final AppointmentRepository appointmentRepository;
  final StorageService storageService;

  BookAppointmentController({
    required this.appointmentRepository,
    required this.storageService,
  });

  // Doctor data (passed from previous screen)
  late DoctorModel doctor;

  // State
  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<String>();
  final availableSlots = <String>[].obs;
  final isLoadingSlots = false.obs;
  final reasonController = TextEditingController();

  // Calendar
  final focusedDay = DateTime.now().obs;
  final selectedMonth = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();

    // Get doctor from arguments
    if (Get.arguments is DoctorModel) {
      doctor = Get.arguments as DoctorModel;
    }

    // Select today as initial date
    final today = DateTime.now();
    selectedDate.value = today;
    focusedDay.value = today;

    // Load slots for today
    loadAvailableSlots(today);
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  /// Load available slots for a specific date
  Future<void> loadAvailableSlots(DateTime date) async {
    try {
      isLoadingSlots.value = true;
      availableSlots.clear();
      selectedTime.value = null;

      final slots = await appointmentRepository.getAvailableSlots(
        doctorId: doctor.id,
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

  /// Select a date
  void selectDate(DateTime date) {
    selectedDate.value = date;
    focusedDay.value = date;
    loadAvailableSlots(date);
  }

  /// Select a time slot
  void selectTimeSlot(String time) {
    selectedTime.value = time;
  }

  /// Check if date is selectable
  bool isDateSelectable(DateTime date) {
    // Can't select past dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate.isBefore(today)) {
      return false;
    }

    // Can select dates up to 30 days in advance
    final maxDate = today.add(const Duration(days: 30));
    return checkDate.isBefore(maxDate) || checkDate.isAtSameMomentAs(maxDate);
  }

  /// Book appointment
  Future<void> bookAppointment() async {
    // Validation
    if (selectedDate.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedTime.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner un créneau horaire',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get current user
      final user = await storageService.getUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Book appointment
      final appointment = await appointmentRepository.bookAppointment(
        patientId: user.id,
        doctorId: doctor.id,
        date: selectedDate.value!,
        time: selectedTime.value!,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      // Show success message
      Get.back(); // Close booking screen

      Get.snackbar(
        'Succès',
        'Rendez-vous confirmé pour le ${appointment.formattedDate} à ${appointment.appointmentTime}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Navigate to appointments screen
      Get.toNamed('/appointments');
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

  /// Change month
  void changeMonth(int delta) {
    final newMonth = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + delta,
    );
    selectedMonth.value = newMonth;
    focusedDay.value = newMonth;
  }
}
