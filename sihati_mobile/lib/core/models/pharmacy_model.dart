class PharmacyModel {
  final int id;
  final String pharmacyName;
  final String address;
  final String wilaya;
  final String? commune;
  final double latitude;
  final double longitude;
  final String phone;
  final String? whatsappNumber;
  final Map<String, dynamic>? openingHours;
  final bool isOnDutyTonight;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional: distance from user (calculated, not from DB)
  final double? distance;

  PharmacyModel({
    required this.id,
    required this.pharmacyName,
    required this.address,
    required this.wilaya,
    this.commune,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.whatsappNumber,
    this.openingHours,
    this.isOnDutyTonight = false,
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  // Create PharmacyModel from JSON
  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'] as int,
      pharmacyName: json['pharmacyName'] ?? json['pharmacy_name'] ?? '',
      address: json['address'] as String,
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      whatsappNumber: json['whatsappNumber'] ?? json['whatsapp_number'],
      openingHours: json['openingHours'] ?? json['opening_hours'],
      isOnDutyTonight:
          json['isOnDutyTonight'] ?? json['is_on_duty_tonight'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

  // Convert PharmacyModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacyName': pharmacyName,
      'address': address,
      'wilaya': wilaya,
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'openingHours': openingHours,
      'isOnDutyTonight': isOnDutyTonight,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'distance': distance,
    };
  }

  // Helper: Get full address
  String get fullAddress {
    if (commune != null && commune!.isNotEmpty) {
      return '$address, $commune, $wilaya';
    }
    return '$address, $wilaya';
  }

  // Helper: Get formatted distance
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  // Helper: Check if has WhatsApp
  bool get hasWhatsapp => whatsappNumber != null && whatsappNumber!.isNotEmpty;

  // Helper: Get opening hours for a specific day
  Map<String, String>? getHoursForDay(String day) {
    if (openingHours == null) return null;

    final dayLower = day.toLowerCase();
    if (openingHours!.containsKey(dayLower)) {
      final hours = openingHours![dayLower];
      if (hours is Map) {
        return {
          'open': hours['open']?.toString() ?? '',
          'close': hours['close']?.toString() ?? '',
        };
      }
    }
    return null;
  }

  // Helper: Check if open on a specific day
  bool isOpenOnDay(String day) {
    final hours = getHoursForDay(day);
    if (hours == null) return false;
    return hours['open'] != null &&
        hours['open']!.isNotEmpty &&
        hours['open'] != 'null';
  }

  // Helper: Get status badge text
  String get statusBadge {
    return isOnDutyTonight ? 'OPEN NOW' : 'CLOSED';
  }

  // CopyWith method
  PharmacyModel copyWith({
    int? id,
    String? pharmacyName,
    String? address,
    String? wilaya,
    String? commune,
    double? latitude,
    double? longitude,
    String? phone,
    String? whatsappNumber,
    Map<String, dynamic>? openingHours,
    bool? isOnDutyTonight,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
  }) {
    return PharmacyModel(
      id: id ?? this.id,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      address: address ?? this.address,
      wilaya: wilaya ?? this.wilaya,
      commune: commune ?? this.commune,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      openingHours: openingHours ?? this.openingHours,
      isOnDutyTonight: isOnDutyTonight ?? this.isOnDutyTonight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return 'PharmacyModel(id: $id, name: $pharmacyName, wilaya: $wilaya, onDuty: $isOnDutyTonight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PharmacyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
