import 'package:flutter/material.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';

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

  String get fullAddress {
    if (commune != null && commune!.isNotEmpty) {
      return '$address, $commune, $wilaya';
    }
    return '$address, $wilaya';
  }

  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  bool get hasWhatsapp => whatsappNumber != null && whatsappNumber!.isNotEmpty;

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

  bool isOpenOnDay(String day) {
    final hours = getHoursForDay(day);
    if (hours == null) return false;
    return hours['open'] != null &&
        hours['open']!.isNotEmpty &&
        hours['open'] != 'null';
  }

  bool get isOpenNow {
    if (openingHours == null || openingHours!.isEmpty) {
      return isOnDutyTonight;
    }
    final now = DateTime.now();
    final currentDay = _getDayOfWeek(now.weekday);
    final currentTime = _timeToMinutes(now.hour, now.minute);
    final hours = getHoursForDay(currentDay);
    if (hours == null) return isOnDutyTonight;
    final openTime = _timeStringToMinutes(hours['open']);
    final closeTime = _timeStringToMinutes(hours['close']);
    if (openTime == null || closeTime == null) return isOnDutyTonight;
    if (closeTime < openTime) {
      return currentTime >= openTime || currentTime <= closeTime;
    } else {
      return currentTime >= openTime && currentTime <= closeTime;
    }
  }

  String get statusText {
    return isOpenNow ? 'Ouverte' : 'Fermée';
  }

  Color get statusColor {
    return isOpenNow ? AppColors.success : AppColors.error;
  }

  IconData get statusIcon {
    return isOpenNow ? Icons.check_circle_rounded : Icons.cancel_rounded;
  }

  String _getDayOfWeek(int weekday) {
    const days = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    return days[weekday] ?? 'monday';
  }

  int? _timeStringToMinutes(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  int _timeToMinutes(int hour, int minute) {
    return hour * 60 + minute;
  }

  String get todayHours {
    if (openingHours == null) return 'Horaires non disponibles';
    final currentDay = _getDayOfWeek(DateTime.now().weekday);
    final hours = getHoursForDay(currentDay);
    if (hours == null) return 'Fermé aujourd\'hui';
    final open = hours['open'] ?? '--:--';
    final close = hours['close'] ?? '--:--';
    return '$open - $close';
  }

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
