// lib/app/constants/api_constants.dart
class ApiConstants {
  // Base URL
  static const String BASE_URL = 'https://sihati-1.onrender.com/api';

  // Authentication endpoints
  static const String LOGIN = '/auth/login';
  static const String REGISTER_PATIENT = '/auth/patient/register';
  static const String REGISTER_PHARMACY = '/auth/pharmacy/register';
  static const String REGISTER_DOCTOR = '/auth/doctor/register';
  static const String PROFILE = '/auth/profile';
  static const String LOGOUT = '/auth/logout';
  static const String REFRESH_TOKEN = '/auth/refresh-token';
  static const String UPDATE_CHIFA = '/user/chifa';

  // 🆕 Appointment endpoints
  static const String APPOINTMENTS = '/appointments';
  static const String MY_APPOINTMENTS = '/appointments/my';

  // Pharmacy endpoints
  static const String PHARMACIES = '/pharmacies';
  static const String PHARMACY_DETAIL = '/pharmacies';
  static const String DUTY_PHARMACIES = '/pharmacies/duty';
  static const String NEARBY_PHARMACIES = '/pharmacies/nearby';
  static const String PHARMACY_PROFILE = '/pharmacy/profile';
  static const String PHARMACY_STOCK = '/pharmacy/stock';

  // Medication endpoints
  static const String MEDICATION_SEARCH = '/medications/search';
  static const String MEDICATIONS = '/medications';

  // Doctor endpoints
  static const String DOCTORS = '/doctors';
  static const String DOCTOR_DETAIL = '/doctors';
  static const String DOCTOR_SEARCH = '/doctors/search';
  static const String SPECIALTIES = '/specialties';
  static const String DOCTOR_PROFILE = '/doctor/profile';

  // Timeouts
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 30);
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 30);
}
