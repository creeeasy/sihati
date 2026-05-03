import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

// ========================================
// TAB 3: HISTORIQUE MÉDICAMENTS
// ========================================

class HistoriqueMedicamentsTabContent extends StatefulWidget {
  @override
  _HistoriqueMedicamentsTabContentState createState() =>
      _HistoriqueMedicamentsTabContentState();
}

class _HistoriqueMedicamentsTabContentState
    extends State<HistoriqueMedicamentsTabContent> {
  bool showActiveOnly = false;

  final List<MedicationHistory> medications = [
    MedicationHistory(
      name: 'Doliprane 1000mg',
      type: 'Antalgique',
      startDate: DateTime(2026, 3, 15),
      endDate: DateTime(2026, 3, 22),
      dosage: '1 comprimé, 3x par jour',
      reason: 'Grippe',
      prescribedBy: 'Dr. Sarah Mansouri',
      isActive: true,
    ),
    MedicationHistory(
      name: 'Amoxicilline 500mg',
      type: 'Antibiotique',
      startDate: DateTime(2026, 3, 15),
      endDate: DateTime(2026, 3, 25),
      dosage: '1 gélule, 2x par jour',
      reason: 'Infection',
      prescribedBy: 'Dr. Sarah Mansouri',
      isActive: true,
    ),
    MedicationHistory(
      name: 'Aspirine 100mg',
      type: 'Anti-coagulant',
      startDate: DateTime(2026, 1, 10),
      endDate: null, // Continuous
      dosage: '1 comprimé, 1x par jour',
      reason: 'Prévention cardiovasculaire',
      prescribedBy: 'Dr. Amina Zeroual',
      isActive: true,
    ),
    MedicationHistory(
      name: 'Ibuprofène 400mg',
      type: 'Anti-inflammatoire',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 2, 7),
      dosage: '1 comprimé, 2x par jour',
      reason: 'Douleurs musculaires',
      prescribedBy: 'Dr. Karim Benali',
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMeds = showActiveOnly
        ? medications.where((m) => m.isActive).toList()
        : medications;

    return Column(
      children: [
        // Filter bar
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filteredMeds.length} médicaments',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.file_download, size: 18),
                    label: Text('Exporter'),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Toggle active only
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showActiveOnly = !showActiveOnly;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: showActiveOnly
                              ? AppColors.primarySoft
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: showActiveOnly
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              showActiveOnly
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: showActiveOnly
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Afficher seulement les traitements en cours',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: showActiveOnly
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: showActiveOnly,
                    onChanged: (value) {
                      setState(() {
                        showActiveOnly = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: filteredMeds.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return _buildMedicationCard(filteredMeds[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(MedicationHistory med) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: med.isActive
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: med.isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:
                  med.isActive ? AppColors.primarySoft : AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: med.isActive
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: med.isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        med.type,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: med.isActive
                        ? AppColors.success
                        : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    med.isActive ? 'En cours' : 'Terminé',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dosage
                _buildInfoRow(
                  Icons.access_time,
                  'Posologie',
                  med.dosage,
                ),

                SizedBox(height: AppSpacing.sm),

                // Dates
                _buildInfoRow(
                  Icons.calendar_today,
                  'Période',
                  '${_formatDate(med.startDate)} - ${med.endDate != null ? _formatDate(med.endDate!) : "En continu"}',
                ),

                SizedBox(height: AppSpacing.sm),

                // Reason
                _buildInfoRow(
                  Icons.note_outlined,
                  'Raison',
                  med.reason,
                ),

                SizedBox(height: AppSpacing.sm),

                // Prescribed by
                _buildInfoRow(
                  Icons.person_outline,
                  'Prescrit par',
                  med.prescribedBy,
                ),

                if (med.isActive) ...[
                  SizedBox(height: AppSpacing.md),

                  // Progress bar
                  _buildProgressBar(med),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(MedicationHistory med) {
    if (med.endDate == null) {
      // Continuous treatment
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.all_inclusive,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Traitement continu',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate progress
    final now = DateTime.now();
    final total = med.endDate!.difference(med.startDate).inDays;
    final elapsed = now.difference(med.startDate).inDays;
    final progress = (elapsed / total).clamp(0.0, 1.0);
    final daysLeft = med.endDate!.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              daysLeft > 0 ? '$daysLeft jours restants' : 'Terminé',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Model
class MedicationHistory {
  final String name;
  final String type;
  final DateTime startDate;
  final DateTime? endDate;
  final String dosage;
  final String reason;
  final String prescribedBy;
  final bool isActive;

  MedicationHistory({
    required this.name,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.dosage,
    required this.reason,
    required this.prescribedBy,
    required this.isActive,
  });
}
