import 'package:get_it/get_it.dart';
import 'package:qubi/core/app_settings_service.dart';
import 'package:qubi/features/devices/infrastructure/ble/device_scanner.dart';
import 'package:qubi/features/devices/infrastructure/ble/flutter_blue_plus_client.dart';
import 'package:qubi/features/devices/infrastructure/repositories/devices_repository_ble.dart';
import 'package:qubi/features/devices/infrastructure/repositories/devices_repository_ble_interface.dart';
import 'package:qubi/features/devices/infrastructure/repositories/sim_devices_repository_ble.dart';
import 'package:qubi/features/devices/services/devices_service.dart';

void registerDeviceDependencies() {

  final g = GetIt.instance;

  final simulateBle = g<AppSettingsService>().SIMULATE_BLE;
  final scanForQubiOnly = g<AppSettingsService>().SCAN_ONLY_QUBI;

  g.registerLazySingleton<FlutterBluePlusClient>(() => FlutterBluePlusClient());
  g.registerLazySingleton<DeviceScanner>(() => DeviceScanner(fbp: g<FlutterBluePlusClient>(), scanForQubiOnly: scanForQubiOnly));

  if(simulateBle) {
    g.registerLazySingleton<IDevicesRepository>(() => SimDevicesRepository());
  } else {
    g.registerLazySingleton<IDevicesRepository>(() => DevicesRepositoryBle(
      fbp: g<FlutterBluePlusClient>(),
      scanner: g<DeviceScanner>(),
    ));
  }

  g.registerLazySingleton<DevicesService>(() => DevicesService(g<IDevicesRepository>()));

}