enum UrgencyLevel { low, medium, high, emergency }

UrgencyLevel urgencyFromString(String? s) {
  switch (s) {
    case 'emergency':
      return UrgencyLevel.emergency;
    case 'high':
      return UrgencyLevel.high;
    case 'medium':
      return UrgencyLevel.medium;
    default:
      return UrgencyLevel.low;
  }
}

class ChatResponse {
  final String reply;
  final UrgencyLevel urgency;
  final bool isSymptomRelated;
  final String? suggestedSpecialty;
  final List<AIMedicationResult> medicationSuggestions;

  ChatResponse.fromJson(Map<String, dynamic> j)
      : reply = j['reply'] ?? '',
        urgency = urgencyFromString(j['urgency']),
        isSymptomRelated = j['isSymptomRelated'] ?? false,
        suggestedSpecialty = j['suggestedSpecialty'],
        medicationSuggestions = (j['medicationSuggestions'] as List? ?? [])
            .map((m) => AIMedicationResult.fromJson(m))
            .toList();
}

class AIMedicationResult {
  final String name;
  final String? genericName;
  final String? category;
  final bool requiresPrescription;
  final double? basePrice;
  final bool foundInDb;
  final List<PharmacyStock> availableInPharmacies;

  AIMedicationResult.fromJson(Map<String, dynamic> j)
      : name = j['name'] ?? '',
        genericName = j['genericName'],
        category = j['category'],
        requiresPrescription = j['requiresPrescription'] ?? false,
        basePrice = (j['basePrice'] as num?)?.toDouble(),
        foundInDb = j['foundInDb'] ?? false,
        availableInPharmacies = (j['availableInPharmacies'] as List? ?? [])
            .map((p) => PharmacyStock.fromJson(p))
            .toList();

  bool get hasStock => availableInPharmacies.any((p) => p.inStock);
  int get stockCount => availableInPharmacies.where((p) => p.inStock).length;
}

class PharmacyStock {
  final String pharmacyId;
  final String pharmacyName;
  final String wilaya;
  final String phone;
  final bool isOnDutyTonight;
  final bool inStock;
  final double? price;
  final double? distance;

  PharmacyStock.fromJson(Map<String, dynamic> j)
      : pharmacyId = j['pharmacyId']?.toString() ?? '',
        pharmacyName = j['pharmacyName'] ?? '',
        wilaya = j['wilaya'] ?? '',
        phone = j['phone'] ?? '',
        isOnDutyTonight = j['isOnDutyTonight'] ?? false,
        inStock = j['inStock'] ?? false,
        price = (j['price'] as num?)?.toDouble(),
        distance = (j['distance'] as num?)?.toDouble();
}

class HistoryItem {
  final String role;
  final String text;

  HistoryItem({required this.role, required this.text});

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': [
          {'text': text}
        ],
      };
}
