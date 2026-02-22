/// Validation utility class
/// Provides common validation functions for forms
/// Returns error message string or null if valid
class Validators {
  // ==================== EMAIL ====================

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }

    return null;
  }

  /// Check if email is valid (boolean)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  // ==================== PASSWORD ====================

  /// Validate password (minimum 8 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 8) {
      return 'Mot de passe doit contenir au moins 8 caractères';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation du mot de passe requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  // ==================== PHONE NUMBER ====================

  /// Validate Algerian phone number (10 digits starting with 0)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }

    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    // Algerian phone: 10 digits starting with 0 (05, 06, 07)
    final phoneRegex = RegExp(r'^0[5-7][0-9]{8}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Numéro invalide (format: 05XXXXXXXX)';
    }

    return null;
  }

  /// Check if phone is valid (boolean)
  static bool isValidAlgerianPhone(String phone) {
    return validatePhoneNumber(phone) == null;
  }

  // ==================== REQUIRED FIELDS ====================

  /// Validate required field
  static String? validateRequired(String? value,
      [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  // ==================== NAME ====================

  /// Validate name (minimum 3 characters)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }

    if (value.trim().length < 3) {
      return 'Nom doit contenir au moins 3 caractères';
    }

    return null;
  }

  /// Validate full name (first and last name)
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom complet requis';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Nom complet doit contenir au moins 3 caractères';
    }

    // Check if contains at least 2 words
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length < 2) {
      return 'Veuillez entrer votre nom et prénom';
    }

    return null;
  }

  // ==================== NUMBER ====================

  /// Validate number
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre requis';
    }

    if (double.tryParse(value) == null) {
      return 'Nombre invalide';
    }

    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value) {
    final error = validateNumber(value);
    if (error != null) return error;

    final number = double.parse(value!);
    if (number <= 0) {
      return 'Le nombre doit être positif';
    }

    return null;
  }

  /// Validate integer
  static String? validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre requis';
    }

    if (int.tryParse(value) == null) {
      return 'Nombre entier requis';
    }

    return null;
  }

  // ==================== ADDRESS ====================

  /// Validate address (minimum 10 characters)
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Adresse requise';
    }

    if (value.trim().length < 10) {
      return 'Adresse doit contenir au moins 10 caractères';
    }

    return null;
  }

  // ==================== TEXT LENGTH ====================

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength,
      [String fieldName = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    if (value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength,
      [String fieldName = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (value.length > maxLength) {
      return '$fieldName ne doit pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Validate length range
  static String? validateLengthRange(
    String? value,
    int minLength,
    int maxLength, [
    String fieldName = 'Ce champ',
  ]) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    if (value.length < minLength || value.length > maxLength) {
      return '$fieldName doit contenir entre $minLength et $maxLength caractères';
    }

    return null;
  }

  // ==================== SPECIAL VALIDATIONS ====================

  /// Validate medication name (for search)
  static String? validateMedicationSearch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom du médicament requis';
    }

    if (value.length < 2) {
      return 'Veuillez entrer au moins 2 caractères';
    }

    return null;
  }

  /// Validate wilaya selection
  static String? validateWilaya(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner une wilaya';
    }

    return null;
  }

  /// Validate consultation fee
  static String? validateConsultationFee(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Montant invalide';
    }

    if (number < 0) {
      return 'Le montant ne peut pas être négatif';
    }

    if (number > 100000) {
      return 'Montant trop élevé';
    }

    return null;
  }

  // ==================== UTILITY ====================

  /// Check if string is empty or null
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if string is not empty
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }
}
