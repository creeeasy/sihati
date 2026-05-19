import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/medical_document_model.dart';

class DocumentsTab extends GetView<MedicalRecordController> {
  const DocumentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.medicalDocuments.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      if (controller.medicalDocuments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 80,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Aucun document',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Vos documents médicaux apparaîtront ici',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                text: 'Ajouter un document',
                icon: Icons.cloud_upload_rounded,
                onPressed: controller.uploadDocument,
                isOutlined: true,
                width: 200,
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => controller.refreshData(),
        color: AppColors.primary,
        child: Column(
          children: [
            // Upload button at top
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Ajouter un document',
                      icon: Icons.cloud_upload_rounded,
                      onPressed: controller.uploadDocument,
                      isOutlined: true,
                      height: 44,
                    ),
                  ),
                ],
              ),
            ),
            // Documents list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: controller.medicalDocuments.length,
                itemBuilder: (context, index) {
                  final document = controller.medicalDocuments[index];
                  return _buildDocumentCard(document);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDocumentCard(MedicalDocument document) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDocument(document),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Document icon with type color
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getDocumentColor(document.documentType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDocumentIcon(document.documentType),
                    color: _getDocumentColor(document.documentType),
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Document info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.documentTypeDisplayName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: _getDocumentColor(document.documentType),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(document.documentDate),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.file_present_outlined,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            document.formattedFileSize,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  children: [
                    // Download button
                    IconButton(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      onPressed: () => _downloadDocument(document),
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                      onPressed: () => _showDeleteConfirmation(document),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(MedicalDocument document) async {
    try {
      // TODO: Implement document opening
      Get.snackbar(
        'Document',
        'Ouverture du document: ${document.title}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadDocument(MedicalDocument document) async {
    await controller.downloadDocument(document);
  }

  Future<void> _showDeleteConfirmation(MedicalDocument document) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text(
          'Voulez-vous vraiment supprimer "${document.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // ✅ Utiliser la méthode publique du controller
        await controller.deleteDocument(document.id);
        // deleteDocument appelle déjà refreshData()
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer le document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.labResult:
        return Icons.science_rounded;
      case DocumentType.radiology:
        return Icons.health_and_safety_rounded;
      case DocumentType.report:
        return Icons.article_rounded;
      case DocumentType.certificate:
        return Icons.assignment_rounded;
      case DocumentType.prescription:
        return Icons.medication_rounded;
      case DocumentType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.labResult:
        return Colors.purple;
      case DocumentType.radiology:
        return Colors.blue;
      case DocumentType.report:
        return Colors.orange;
      case DocumentType.certificate:
        return Colors.green;
      case DocumentType.prescription:
        return Colors.teal;
      case DocumentType.other:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
