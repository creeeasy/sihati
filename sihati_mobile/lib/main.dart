import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'core/services/storage_service.dart';
import 'core/services/location_service.dart';
import 'core/services/favorites_service.dart';
import 'core/services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const SihatiApp());
}

Future<void> initServices() async {
  print('🚀 Initializing services...');

  try {
    await Get.putAsync(() => StorageService().init());
    print('✓ Storage service');

    await Get.putAsync(() => LocationService().init());
    print('✓ Location service');

    await Get.putAsync(() => FavoritesService().init());
    print('✓ Favorites service');

    await Get.putAsync(() => AIService().init());
    print('✓ AI service');

    print('✅ All services ready!');
  } catch (e) {
    print('❌ Service error: $e');
  }
}

class SihatiApp extends StatelessWidget {
  const SihatiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sihati',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
