import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicalRecordController extends GetxController {
  // Tab index
  final tabIndex = 0.obs;

  // Data states
  final isLoading = false.obs;

  // Statistics
  final ordonnancesCount = 12.obs;
  final medicationsCount = 24.obs;
  final consultationsCount = 8.obs;
  final documentsCount = 15.obs;

  // Allergies
  final allergies = <String>['Pénicilline', 'Aspirine'].obs;

  // Current medications
  final currentMedications = <Map<String, dynamic>>[
    {
      'name': 'Doliprane 1000mg',
      'dosage': '1 comprimé, 3x par jour',
      'duration': 'Jusqu\'au 25 Mars',
      'color': 0xFF2E7BF6, // AppColors.primary
    },
    {
      'name': 'Amoxicilline 500mg',
      'dosage': '1 gélule, 2x par jour',
      'duration': 'Jusqu\'au 28 Mars',
      'color': 0xFF4CAF50, // AppColors.success
    },
  ].obs;

  // Last consultation
  final lastConsultation = {
    'date': '15 Mars 2026',
    'doctor': 'Dr. Sarah Mansouri',
    'specialty': 'Médecin Généraliste',
    'status': 'Terminée',
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedicalData();
  }

  Future<void> loadMedicalData() async {
    try {
      isLoading.value = true;
      // TODO: Load real data from repository
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error loading medical data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void goBack() {
    Get.back();
  }

  void viewPrescription(String prescriptionId) {
    // TODO: Navigate to prescription detail
    Get.snackbar(
      'Ordonnance',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addAllergy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter une allergie'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom de l\'allergie',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              allergies.add(value);
              Get.back();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final textField =
                  Get.context?.findAncestorWidgetOfExactType<TextField>();
              // This needs proper implementation
              Get.back();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void removeAllergy(String allergy) {
    allergies.remove(allergy);
  }

  void addMedication() {
    // TODO: Navigate to add medication screen
    Get.snackbar(
      'Médicament',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void refreshData() async {
    await loadMedicalData();
  }

  String getFormattedDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[month - 1];
  }
}
