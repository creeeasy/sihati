// lib/core/models/user_model.dart
//
// Matches backend: User.ts (underscored: true → snake_case JSON keys)
// Fields: id, email, role, fullName→full_name, phoneNumber→phone_number,
//   chifaNumber→chifa_number, isVerified→is_verified, wilaya, address,
//   profileImage→profile_image, lastLogin→last_login, createdAt→created_at,
//   updatedAt→updated_at
// password is stripped by toJSON()
class UserModel {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String phoneNumber;
  final String? chifaNumber;
  final bool isVerified;
  final String? wilaya;
  final String? address;
  final String? profileImage;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.phoneNumber,
    this.chifaNumber,
    this.isVerified = false,
    this.wilaya,
    this.address,
    this.profileImage,
    this.lastLogin,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      chifaNumber: json['chifaNumber'] ?? json['chifa_number'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      wilaya: json['wilaya'],
      address: json['address'],
      profileImage: json['profileImage'] ?? json['profile_image'],
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : json['last_login'] != null
              ? DateTime.tryParse(json['last_login'].toString())
              : null,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      if (chifaNumber != null && chifaNumber!.isNotEmpty)
        'chifaNumber': chifaNumber,
      'isVerified': isVerified,
      if (wilaya != null) 'wilaya': wilaya,
      if (address != null) 'address': address,
      if (profileImage != null) 'profileImage': profileImage,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isPatient => role == 'patient';
  bool get isPharmacy => role == 'pharmacy';
  bool get isDoctor => role == 'doctor';
  bool get isAdmin => role == 'admin';

  bool get hasChifa => chifaNumber != null && chifaNumber!.isNotEmpty;

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

  String get initials {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? fullName,
    String? phoneNumber,
    String? chifaNumber,
    bool? isVerified,
    String? wilaya,
    String? address,
    String? profileImage,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      chifaNumber: chifaNumber ?? this.chifaNumber,
      isVerified: isVerified ?? this.isVerified,
      wilaya: wilaya ?? this.wilaya,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: $role, fullName: $fullName, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
