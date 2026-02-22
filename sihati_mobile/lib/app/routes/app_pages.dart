import 'package:get/get.dart';
import 'package:sihati_mobile/modules/ai_assistant/bindings/ai_assistant_binding.dart';
import 'package:sihati_mobile/modules/ai_assistant/views/ai_assistant_screen.dart';
import 'package:sihati_mobile/modules/favorites/views/favorites_screen.dart';
import 'app_routes.dart';

// Splash
import '../../modules/splash/views/splash_screen.dart';
import '../../modules/splash/bindings/splash_binding.dart';

// Auth
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/auth/bindings/auth_binding.dart';

// Home
import '../../modules/home/views/home_screen.dart';
import '../../modules/home/bindings/home_binding.dart';

// Pharmacies
import '../../modules/pharmacies/views/pharmacy_list_screen.dart';
import '../../modules/pharmacies/views/pharmacy_detail_screen.dart';
import '../../modules/pharmacies/views/duty_pharmacy_screen.dart';
import '../../modules/pharmacies/bindings/pharmacy_binding.dart';

// Medications
import '../../modules/medications/views/medication_search_screen.dart';
import '../../modules/medications/bindings/medication_binding.dart';

// Doctors
import '../../modules/doctors/views/doctor_list_screen.dart';
import '../../modules/doctors/views/doctor_detail_screen.dart';
import '../../modules/doctors/bindings/doctor_binding.dart';

// Profile
import '../../modules/profile/views/profile_screen.dart';
import '../../modules/profile/bindings/profile_binding.dart';

class AppPages {
  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),

    // Home
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),

    // Pharmacies
    GetPage(
      name: AppRoutes.PHARMACY_LIST,
      page: () => const PharmacyListScreen(),
      binding: PharmacyBinding(),
    ),
    GetPage(
      name: '${AppRoutes.PHARMACY_DETAIL}/:id',
      page: () => const PharmacyDetailScreen(),
      binding: PharmacyBinding(),
    ),
    GetPage(
      name: AppRoutes.DUTY_PHARMACIES,
      page: () => const DutyPharmacyScreen(),
      binding: PharmacyBinding(),
    ),

    // Medications
    GetPage(
      name: AppRoutes.MEDICATION_SEARCH,
      page: () => const MedicationSearchScreen(),
      binding: MedicationBinding(),
    ),

    // Doctors
    GetPage(
      name: AppRoutes.DOCTOR_LIST,
      page: () => const DoctorListScreen(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: '${AppRoutes.DOCTOR_DETAIL}/:id',
      page: () => const DoctorDetailScreen(),
      binding: DoctorBinding(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),

    // Favorites
    GetPage(
      name: AppRoutes.FAVORITES,
      page: () => const FavoritesScreen(),
    ),
    // AI Assistant
    GetPage(
      name: AppRoutes.AI_ASSISTANT,
      page: () => const AIAssistantScreen(),
      binding: AIAssistantBinding(),
    ),
  ];
}
