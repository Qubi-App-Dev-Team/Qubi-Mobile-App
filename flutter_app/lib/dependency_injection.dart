import 'package:get_it/get_it.dart';
import 'package:qubi/core/app_settings_service.dart';
import 'package:qubi/features/devices/dependency_injection.dart';

final getIt = GetIt.instance;

Future<void> initCoreDI() async {
  getIt.registerLazySingleton<AppSettingsService>(() => AppSettingsService());

  await getIt<AppSettingsService>().init();

  registerDeviceDependencies();
  
}