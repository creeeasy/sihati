// lib/core/models/medical_document_model.dart
enum DocumentType {
  labResult,
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
  final DocumentType type;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final DateTime documentDate;
  final DateTime uploadedAt;

  MedicalDocument({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.type,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    required this.documentDate,
    required this.uploadedAt,
  });

  String get formattedFileSize {
    if (fileSize == null) return 'Taille inconnue';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024)
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id'].toString(),
      patientId: json['patientId'].toString(),
      doctorId: json['doctorId']?.toString() ?? json['doctor_id']?.toString(),
      type: _typeFromString(json['type'] ?? json['document_type']),
      title: json['title'],
      description: json['description'],
      fileUrl: json['fileUrl'] ?? json['file_url'],
      fileType: json['fileType'] ?? json['file_type'],
      fileSize: json['fileSize'] ?? json['file_size'],
      documentDate:
          DateTime.parse(json['documentDate'] ?? json['document_date']),
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'type': _typeToString(type),
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'documentDate': documentDate.toIso8601String(),
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  static DocumentType _typeFromString(String type) {
    switch (type.toLowerCase()) {
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
        return 'labResult';
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
    switch (type) {
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
}
