// lib/core/models/pharmacy_with_stock.dart
import 'package:flutter/material.dart';
import 'pharmacy_model.dart';

/// Pharmacy with stock information for a specific medication
class PharmacyWithStock {
  final PharmacyModel pharmacy;
  final bool isAvailable;
  final DateTime? lastUpdated;
  final double? distance;
  final double? price;
  final int? quantity;

  PharmacyWithStock({
    required this.pharmacy,
    this.isAvailable = true,
    this.lastUpdated,
    this.distance,
    this.price,
    this.quantity,
  });

  // ─── Factory Methods ─────────────────────────────────────────

  /// Create from JSON
  factory PharmacyWithStock.fromJson(Map<String, dynamic> json) {
    return PharmacyWithStock(
      pharmacy: PharmacyModel.fromJson(json['pharmacy'] ?? json),
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      lastUpdated: _parseDateTime(json['lastUpdated'] ?? json['last_updated']),
      distance: _parseDouble(json['distance']),
      price: _parseDouble(json['price']),
      quantity: _parseInt(json['quantity']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = pharmacy.toJson();
    json['isAvailable'] = isAvailable;
    if (lastUpdated != null)
      json['lastUpdated'] = lastUpdated!.toIso8601String();
    if (distance != null) json['distance'] = distance;
    if (price != null) json['price'] = price;
    if (quantity != null) json['quantity'] = quantity;
    return json;
  }

  // ─── Helper Getters ──────────────────────────────────────────

  /// Get pharmacy ID (String UUID)
  String get pharmacyId => pharmacy.id;

  /// Get pharmacy name
  String get pharmacyName => pharmacy.pharmacyName;

  /// Get stock status text
  String get stockStatus {
    if (!isAvailable) return 'Rupture de stock';
    if (quantity != null && quantity! <= 5)
      return 'Stock faible ($quantity restant${quantity! > 1 ? 's' : ''})';
    return 'En stock';
  }

  /// Get stock status color
  Color get stockStatusColor {
    if (!isAvailable) return Colors.red;
    if (quantity != null && quantity! <= 5) return Colors.orange;
    return Colors.green;
  }

  /// Get last updated text
  String get lastUpdatedText {
    if (lastUpdated == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);

    if (difference.inMinutes < 60) {
      return 'Mis à jour il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Mis à jour il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Mis à jour il y a ${difference.inDays}j';
    } else {
      return 'Mis à jour le ${_formatDate(lastUpdated!)}';
    }
  }

  /// Get formatted distance
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  /// Get formatted price
  String get formattedPrice {
    if (price == null) return 'Prix non disponible';
    return '${price!.toStringAsFixed(0)} DA';
  }

  /// Get quantity display
  String get quantityDisplay {
    if (quantity == null) return '';
    if (quantity == 0) return 'Rupture';
    if (quantity! <= 5) return '⚠️ Stock faible ($quantity)';
    return '$quantity en stock';
  }

  // ─── Helper Methods ──────────────────────────────────────────

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ─── CopyWith ────────────────────────────────────────────────

  PharmacyWithStock copyWith({
    PharmacyModel? pharmacy,
    bool? isAvailable,
    DateTime? lastUpdated,
    double? distance,
    double? price,
    int? quantity,
  }) {
    return PharmacyWithStock(
      pharmacy: pharmacy ?? this.pharmacy,
      isAvailable: isAvailable ?? this.isAvailable,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  // ─── Overrides ───────────────────────────────────────────────

  @override
  String toString() {
    return 'PharmacyWithStock(pharmacy: $pharmacyName, isAvailable: $isAvailable, distance: $formattedDistance, price: $formattedPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PharmacyWithStock && other.pharmacyId == pharmacyId;
  }

  @override
  int get hashCode => pharmacyId.hashCode;
}
