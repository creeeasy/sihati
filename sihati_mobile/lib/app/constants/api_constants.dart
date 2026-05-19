// lib/app/constants/api_constants.dart
class ApiConstants {
  // ─── Base URL ──────────────────────────────────────────────────────
  static const String BASE_URL = 'http://192.168.1.102:7500/api';

  // ─── Authentication endpoints ──────────────────────────────────────
  static const String REGISTER = '/auth/register';
  static const String REGISTER_PATIENT = '/auth/register';
  static const String LOGIN = '/auth/login';
  static const String LOGOUT = '/auth/logout';
  static const String REFRESH_TOKEN = '/auth/refresh-token';
  static const String PROFILE = '/auth/profile';
  static const String UPDATE_CHIFA = '/auth/profile/chifa';
  static const String CHANGE_PASSWORD = '/auth/change-password';
  static const String FORGOT_PASSWORD = '/auth/forgot-password';
  static const String RESET_PASSWORD = '/auth/reset-password';
  static const String VERIFY_EMAIL = '/auth/verify-email';

  // ─── Doctor endpoints ──────────────────────────────────────────────
  static const String DOCTORS = '/doctors';
  static const String DOCTOR_DETAIL = '/doctors';
  static const String DOCTOR_SEARCH = '/doctors/search';
  static const String DOCTOR_TOP_RATED = '/doctors/top-rated';
  static const String DOCTOR_AVAILABLE_SLOTS = '/doctors';
  static const String SPECIALTIES = '/doctors/specialties';

  // ─── Pharmacy endpoints ────────────────────────────────────────────
  static const String PHARMACIES = '/pharmacies';
  static const String PHARMACY_DETAIL = '/pharmacies';
  static const String DUTY_PHARMACIES = '/pharmacies/duty';
  static const String NEARBY_PHARMACIES = '/pharmacies/nearby';

  // ─── Medication endpoints ──────────────────────────────────────────
  static const String MEDICATIONS = '/medications';
  static const String MEDICATION_SEARCH = '/medications/search';
  static const String MEDICATION_POPULAR = '/medications/popular';
  static const String MEDICATION_BARCODE = '/medications/barcode';
  static const String MEDICATION_PHARMACIES = '/medications';

  // ─── Appointment endpoints ─────────────────────────────────────────
  static const String APPOINTMENTS = '/appointments';
  static const String APPOINTMENTS_PATIENT = '/appointments/patient';
  static const String APPOINTMENT_CANCEL = '/appointments';

  // ─── Patient endpoints ─────────────────────────────────────────────
  static const String PATIENT_PROFILE = '/patient/profile';
  static const String PATIENT_STATS = '/patient/stats';
  static const String PATIENT_ALLERGIES = '/patient/allergies';
  static const String PATIENT_PRESCRIPTIONS = '/patient/prescriptions';
  static const String PATIENT_CONSULTATIONS = '/patient/consultations';
  static const String PATIENT_DOCUMENTS = '/patient/documents';

  // ─── Favorites endpoints ────────────────────────────────────────────
  static const String FAVORITES_DOCTORS = '/favorites/doctors';
  static const String FAVORITES_PHARMACIES = '/favorites/pharmacies';
  static const String FAVORITES_STATS = '/favorites/stats';

  // ─── AI endpoints ──────────────────────────────────────────────────
  static const String AI_CHAT = '/ai/chat';
  static const String AI_INTERACTION = '/ai/interaction';

  // ─── Timeouts ──────────────────────────────────────────────────────
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 30);
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 30);
}
