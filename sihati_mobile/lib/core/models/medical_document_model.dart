// lib/core/models/medical_document_model.dart
//
// Matches backend: MedicalDocument.ts (underscored: true)
// Fields: id, patientId→patient_id, doctorId→doctor_id,
//   documentType→document_type (ENUM: lab_result|radiology|report|certificate|prescription|other),
//   title, description, fileUrl→file_url, fileType→file_type,
//   fileSizeBytes→file_size_bytes, documentDate→document_date,
//   createdAt→created_at, updatedAt→updated_at
//
// NOTE: There is no 'uploadedAt' field — use createdAt as the upload timestamp.
enum DocumentType {
  labResult,   // 'lab_result'
  radiology,
  report,
  certificate,
  prescription,
  other,
}

class MedicalDocument {
  final String id;
  final String patientId;
  final String? doctorId;
  final DocumentType documentType;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final int? fileSizeBytes;
  final DateTime documentDate;
  final DateTime createdAt;  // used as 'uploaded at' timestamp
  final DateTime? updatedAt;

  MedicalDocument({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.documentType,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.fileSizeBytes,
    required this.documentDate,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedFileSize {
    if (fileSizeBytes == null) return 'Taille inconnue';
    if (fileSizeBytes! < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes! < 1024 * 1024) {
      return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id'].toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      doctorId: json['doctorId']?.toString() ?? json['doctor_id']?.toString(),
      documentType: _typeFromString(
          json['documentType'] ?? json['document_type'] ?? 'other'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      fileUrl: json['fileUrl'] ?? json['file_url'] ?? '',
      fileType: json['fileType'] ?? json['file_type'],
      fileSizeBytes: json['fileSizeBytes'] ?? json['file_size_bytes'],
      documentDate: DateTime.parse(
          (json['documentDate'] ?? json['document_date']).toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      'documentType': _typeToString(documentType),
      'title': title,
      if (description != null) 'description': description,
      'fileUrl': fileUrl,
      if (fileType != null) 'fileType': fileType,
      if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      'documentDate': documentDate.toIso8601String().split('T')[0],
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static DocumentType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'lab_result':
      case 'labresult':
        return DocumentType.labResult;
      case 'radiology':
        return DocumentType.radiology;
      case 'report':
        return DocumentType.report;
      case 'certificate':
        return DocumentType.certificate;
      case 'prescription':
        return DocumentType.prescription;
      default:
        return DocumentType.other;
    }
  }

  static String _typeToString(DocumentType type) {
    switch (type) {
      case DocumentType.labResult:
        return 'lab_result';
      case DocumentType.radiology:
        return 'radiology';
      case DocumentType.report:
        return 'report';
      case DocumentType.certificate:
        return 'certificate';
      case DocumentType.prescription:
        return 'prescription';
      case DocumentType.other:
        return 'other';
    }
  }

  String get typeDisplayName {
    switch (documentType) {
      case DocumentType.labResult:
        return 'Analyse';
      case DocumentType.radiology:
        return 'Radiologie';
      case DocumentType.report:
        return 'Compte-rendu';
      case DocumentType.certificate:
        return 'Certificat';
      case DocumentType.prescription:
        return 'Ordonnance';
      case DocumentType.other:
        return 'Autre';
    }
  }

  /// Alias used by documents_tab.dart
  String get documentTypeDisplayName => typeDisplayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
