import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/services/mapbox_service.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const SihatiApp());
}

Future<void> initServices() async {
  print('🚀 Initializing services...');

  try {
    // ✅ StorageService must be first — ApiService depends on it
    await Get.putAsync(() => StorageService().init());
    print('✓ Storage service');

    // ✅ ApiService registered early so all bindings can find it
    Get.put(ApiService(), permanent: true);
    print('✓ API service');

    await Get.putAsync(() => LocationService().init());
    print('✓ Location service');

    // NotificationService is a singleton, not a GetxService
    // initialize() sets up channels + requests permissions
    await NotificationService().initialize();
    print('✓ Notification service');

    await MapboxService.initialize();
    print('✓ Mapbox service');

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
