import 'dart:async';
import 'dart:developer';

import 'package:qubi/core/helpers/permission_helper.dart';
import 'package:qubi/features/devices/domain/ble_device_info.dart';
import 'package:qubi/features/devices/domain/device_command.dart';
import 'package:qubi/features/devices/domain/device_id.dart';
import 'package:qubi/features/devices/domain/device_state.dart';
import 'package:qubi/features/devices/infrastructure/repositories/devices_repository_ble_interface.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DevicesService {
  final IDevicesRepository _repo;
  final PermissionsHelper _permissions;
  Future<bool>? _adapterReady; // memoized in-flight wait

  DevicesService(this._repo, {PermissionsHelper? permissions})
      : _permissions = permissions ?? PermissionsHelper();

  // Scanning API (unified)
  Stream<List<BleDeviceInfo>> get devices$ => _repo.known();
  bool get isScanning => _repo.isScanning;
  Future<bool> startScanning({Duration timeout = const Duration(seconds: 30)}) async {
    if (!await _permissions.ensureBlePermissions()) return false;
    return _repo.startScan(timeout: timeout);
  }

  Future<void> stopScanning() => _repo.stopScan();

  // Device sessions API
  Stream<DeviceState> observe(String deviceId) => _repo.observe(DeviceId(deviceId));
  Future<void> connect(String deviceId) async {
    if (!await _ensureAdapterOn()) {
      throw StateError('Bluetooth adapter not ON');
    }
    return _repo.connect(DeviceId(deviceId));
  }
  Future<void> disconnect(String deviceId) => _repo.disconnect(DeviceId(deviceId));
  Future<void> send(String deviceId, DeviceCommand cmd) => _repo.send(DeviceId(deviceId), cmd);

  // Convenience wrappers
  Future<void> deepSleep(String deviceId, bool enabled) => send(deviceId, DeviceCommand.deepSleep(enabled));
  Future<void> toggleCharging(String deviceId, bool enabled) => send(deviceId, DeviceCommand.toggleCharging(enabled));
  Future<void> gate(String deviceId, int value) => send(deviceId, DeviceCommand.gate(value));

  //TODO: Move to helper as same function is in device_scanner.dart
  // Wait for BLE adapter to report ON. Mirrors logic used in scanner to avoid
  // early connect attempts during CBManagerStateUnknown.
  Future<bool> _ensureAdapterOn({Duration timeout = const Duration(seconds: 6)}) {
    Future<bool>? existing = _adapterReady;
    if (existing != null) return existing;

    final completer = Completer<bool>();
    _adapterReady = completer.future;

    () async {
      try {
        BluetoothAdapterState first = await FlutterBluePlus.adapterState.first;
        if (first == BluetoothAdapterState.on) {
          log("[INFO] - [devices_service.dart] Bluetooth adapter already ON");
          if (!completer.isCompleted) completer.complete(true);
          return;
        }
        late final StreamSubscription sub;
        sub = FlutterBluePlus.adapterState.listen((s) {
          if (s == BluetoothAdapterState.on) {
            log("[INFO] - [devices_service.dart] Bluetooth adapter switched to ON");
            if (!completer.isCompleted) completer.complete(true);
            sub.cancel();
          } else if (s == BluetoothAdapterState.off ||
              s == BluetoothAdapterState.unavailable ||
              s == BluetoothAdapterState.unauthorized) {
            log("[INFO] - [devices_service.dart] Bluetooth adapter switched to $s");
            if (!completer.isCompleted) completer.complete(false);
            sub.cancel();
          }
        });
        bool ok = await completer.future.timeout(timeout, onTimeout: () => false);
        if (!ok && !completer.isCompleted) {
          completer.complete(false);
        }
      } catch (e, s) {
        log('[ERROR] Error waiting for adapter ON', error: e, stackTrace: s);
        if (!completer.isCompleted) completer.complete(false);
      } finally {
        if (await _adapterReady == false) {
          _adapterReady = null;
        }
      }
    }();

    return _adapterReady!;
  }
}
