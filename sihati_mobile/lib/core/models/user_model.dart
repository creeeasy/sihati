class UserModel {
  final int id;
  final String email;
  final String role; // 'patient', 'pharmacy', 'doctor', 'admin'
  final String fullName;
  final String phoneNumber;
  final String? chifaNumber; // 🆕 Numéro Carte Chifa
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Medical info
  final List<String>? allergies;
  final String? bloodType;

  // Stats
  final int ordonnancesCount;
  final int medicationsCount;
  final int consultationsCount;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.phoneNumber,
    this.chifaNumber,
    this.photoUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.allergies,
    this.bloodType,
    this.ordonnancesCount = 0,
    this.medicationsCount = 0,
    this.consultationsCount = 0,
  });

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      chifaNumber: json['chifaNumber'] ?? json['chifa_number'],
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      bloodType: json['bloodType'] ?? json['blood_type'],
      ordonnancesCount:
          json['ordonnancesCount'] ?? json['ordonnances_count'] ?? 0,
      medicationsCount:
          json['medicationsCount'] ?? json['medications_count'] ?? 0,
      consultationsCount:
          json['consultationsCount'] ?? json['consultations_count'] ?? 0,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      if (chifaNumber != null && chifaNumber!.isNotEmpty)
        'chifaNumber': chifaNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (allergies != null) 'allergies': allergies,
      if (bloodType != null) 'bloodType': bloodType,
      'ordonnancesCount': ordonnancesCount,
      'medicationsCount': medicationsCount,
      'consultationsCount': consultationsCount,
    };
  }

  // Helper method: Check if user is patient
  bool get isPatient => role == 'patient';

  // Helper method: Check if user is pharmacy
  bool get isPharmacy => role == 'pharmacy';

  // Helper method: Check if user is doctor
  bool get isDoctor => role == 'doctor';

  // Helper method: Check if user is admin
  bool get isAdmin => role == 'admin';

  // Helper method: Get initials for avatar
  String get initials {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // Helper method: Check if Chifa is set
  bool get hasChifa => chifaNumber != null && chifaNumber!.isNotEmpty;

  // Get formatted Chifa number (with spaces every 3 digits)
  String? get formattedChifa {
    if (!hasChifa) return null;

    String clean = chifaNumber!.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += ' ';
      }
      formatted += clean[i];
    }
    return formatted;
  }

  // Validate Chifa number format
  bool isValidChifa() {
    if (!hasChifa) return false;
    final clean = chifaNumber!.replaceAll(' ', '');
    return clean.length >= 13 &&
        clean.length <= 15 &&
        RegExp(r'^\d+$').hasMatch(clean);
  }

  // CopyWith method for updating user data
  UserModel copyWith({
    int? id,
    String? email,
    String? role,
    String? fullName,
    String? phoneNumber,
    String? chifaNumber,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? allergies,
    String? bloodType,
    int? ordonnancesCount,
    int? medicationsCount,
    int? consultationsCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      chifaNumber: chifaNumber ?? this.chifaNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      allergies: allergies ?? this.allergies,
      bloodType: bloodType ?? this.bloodType,
      ordonnancesCount: ordonnancesCount ?? this.ordonnancesCount,
      medicationsCount: medicationsCount ?? this.medicationsCount,
      consultationsCount: consultationsCount ?? this.consultationsCount,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: $role, fullName: $fullName, hasChifa: $hasChifa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
