import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/app/theme/app_spacing.dart';
import 'package:sihati_mobile/app/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../controllers/medical_record_controller.dart';
import '../../../../core/models/medical_document_model.dart';

class DocumentsTab extends GetView<MedicalRecordController> {
  const DocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.medicalDocuments.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.medicalDocuments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //SvgPicture.asset(AppIcons.folder, width: 80, height: 80, colorFilter: ColorFilter.mode(AppColors.primary.withOpacity(0.3), BlendMode.srcIn)),
              const SizedBox(height: AppSpacing.md),
              Text('Aucun document',
                  style: AppTextStyles.title
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Text('Vos documents médicaux apparaîtront ici',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                text: 'Ajouter un document',
                svgIcon: AppIcons.upload,
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
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Ajouter un document',
                      svgIcon: AppIcons.upload,
                      onPressed: controller.uploadDocument,
                      isOutlined: true,
                      height: 44,
                    ),
                  ),
                ],
              ),
            ),
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
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppColors.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDocument(document),
          borderRadius: AppSpacing.cardRadius,
          child: Padding(
            padding: AppSpacing.paddingCard,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getDocumentColor(document.documentType)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _getDocumentColor(document.documentType)
                            .withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      _getFileExtension(document.fileUrl),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getDocumentColor(document.documentType),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document.title,
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(document.documentTypeDisplayName,
                          style: AppTextStyles.labelMedium.copyWith(
                              color: _getDocumentColor(document.documentType))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          SvgPicture.asset(AppIcons.calendar,
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textTertiary, BlendMode.srcIn)),
                          const SizedBox(width: 4),
                          Text(_formatDate(document.documentDate),
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textTertiary)),
                          const SizedBox(width: 12),
                          SvgPicture.asset(
                            AppIcons.medicalRecord,
                            width: 12,
                            height: 12,
                            colorFilter: const ColorFilter.mode(
                                AppColors.textTertiary, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 4),
                          Text(document.formattedFileSize,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    AppIcons.search,
                    width: AppSpacing.iconSizeMd,
                    height: AppSpacing.iconSizeMd,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn),
                  ),
                  onPressed: () => _openDocument(document),
                ),
                IconButton(
                  icon: SvgPicture.asset(AppIcons.delete,
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          AppColors.error, BlendMode.srcIn)),
                  onPressed: () => _showDeleteConfirmation(document),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.contains('.')) {
        final ext = path.split('.').last.toUpperCase();
        if (ext.length <= 4) return ext;
        return ext.substring(0, 3);
      }
    } catch (_) {}
    return 'DOC';
  }

  Future<void> _openDocument(MedicalDocument document) async {
    try {
      final uri = Uri.parse(document.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Erreur', 'Impossible d\'ouvrir le document',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ouvrir le document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _showDeleteConfirmation(MedicalDocument document) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            SvgPicture.asset(AppIcons.warning,
                width: 40,
                height: 40,
                colorFilter:
                    const ColorFilter.mode(AppColors.error, BlendMode.srcIn)),
            const SizedBox(height: 16),
            Text('Supprimer le document', style: AppTextStyles.headline),
          ],
        ),
        content: Text('Voulez-vous vraiment supprimer "${document.title}" ?',
            style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text('Annuler',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: Text('Supprimer',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteDocument(document.id);
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
