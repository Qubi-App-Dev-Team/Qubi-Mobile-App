import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:qubi/features/devices/infrastructure/ble/flutter_blue_plus_client.dart';
import 'package:qubi/features/devices/infrastructure/ble/uuids.dart';
import 'package:qubi/features/devices/domain/ble_device_info.dart';

class DeviceScanner {
  final FlutterBluePlusClient fbp;
  final bool scanForQubiOnly;
  final _ctrl = StreamController<List<BleDeviceInfo>>.broadcast();
  StreamSubscription<List<ScanResult>>? _sub;
  bool _scanning = false;

  DeviceScanner({required this.fbp, this.scanForQubiOnly = true});

  Stream<List<BleDeviceInfo>> get devices$ => _ctrl.stream;
  bool get isScanning => _scanning;

  Future<bool> start({Duration timeout = const Duration(seconds: 30)}) async {
    print('[INFO] - [device_scanner.dart] Starting scan for devices (Qubi only: $scanForQubiOnly)');
    if (_scanning) return true;
    //Wait for adapter to be ON
    if (!await _waitForAdapterOn()) return false;

    List<Guid> services;

    if (scanForQubiOnly) {
      services = [Guid.fromString(QubiUuids.qubiServiceUuid)];
    } else {
      services = [];
    }

    await fbp.startScan(services: services, timeout: timeout);

    _sub = fbp.scanResults.listen((results) {
      final list =
          results.map((r) {
              final name =
                  r.device.platformName.isNotEmpty
                      ? r.device.platformName
                      : (r.advertisementData.advName.isNotEmpty ? r.advertisementData.advName : 'Unknown Device');
              return BleDeviceInfo(
                id: r.device.remoteId.toString(),
                name: name,
                address: r.device.remoteId.toString(),
                rssi: r.rssi,
                discoveredAt: DateTime.now(),
              );
            }).toList()
            ..sort((a, b) => b.rssi.compareTo(a.rssi));
      _ctrl.add(list);
    });

    _scanning = true;
    return true;
  }

  Future<void> stop() async {
    if (!_scanning) return;
    await fbp.stopScan();
    await _sub?.cancel();
    _sub = null;
    _scanning = false;
  }

  Future<void> dispose() async {
    await stop();
    await _ctrl.close();
  }

  //TODO: Move to helper as same function is in devices_service.dart
  // Waits for the BLE adapter to reach the ON state, handling transient 'unknown' states.
  Future<bool> _waitForAdapterOn({Duration timeout = const Duration(seconds: 6)}) async {
    try {
      BluetoothAdapterState first = await FlutterBluePlus.adapterState.first;
      if (first == BluetoothAdapterState.on){
        log("[INFO] - [device_scanner.dart] Bluetooth adapter already ON");
        return true;
      }

      final completer = Completer<bool>();
      late final StreamSubscription sub;
      sub = FlutterBluePlus.adapterState.listen((s) {
        if (s == BluetoothAdapterState.on) {
          log("[INFO] - [device_scanner.dart] Bluetooth adapter switched to ON");
          if (!completer.isCompleted) completer.complete(true);
          sub.cancel();
        } else if (s == BluetoothAdapterState.off ||
            s == BluetoothAdapterState.unavailable ||
            s == BluetoothAdapterState.unauthorized) {
          log("[INFO] - [device_scanner.dart] Bluetooth adapter switched to $s");
          if (!completer.isCompleted) completer.complete(false);
          sub.cancel();
        }
      });

      bool ok = await completer.future.timeout(timeout, onTimeout: () => false);
      return ok;
    } catch (e, s) {
      log('[ERROR] Error waiting for adapter ON', error: e, stackTrace: s);
      return false;
    }
  }
}
