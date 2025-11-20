import 'dart:async';
import 'dart:math';
import 'package:qubi/features/devices/domain/ble_device_info.dart';
import 'package:qubi/features/devices/domain/device_command.dart';
import 'package:qubi/features/devices/domain/device_id.dart';
import 'package:qubi/features/devices/domain/device_state.dart';
import 'package:qubi/features/devices/infrastructure/repositories/devices_repository_ble_interface.dart';

class SimDevicesRepository implements IDevicesRepository {
  final _knownCtrl = StreamController<List<BleDeviceInfo>>.broadcast();
  final _stateCtrls = <String, StreamController<DeviceState>>{};
  final _lastState = <String, DeviceState>{};
  final _rng = Random();
  Timer? _scanTimer;
  bool _scanning = false;

  final List<BleDeviceInfo> _devices = [
    BleDeviceInfo(
      id: 'SIM-001',
      name: 'Qubi Alpha',
      address: '00:11:22:33:44:55',
      discoveredAt: DateTime.now(),
      rssi: -50,
    ),
    BleDeviceInfo(
      id: 'SIM-002',
      name: 'Qubi Beta',
      address: '11:22:33:44:55:66',
      discoveredAt: DateTime.now(),
      rssi: -60,
    ),
  ];

  SimDevicesRepository() {
    _emitScan();
  }

  StreamController<DeviceState> _stateCtrl(DeviceId id) {
    return _stateCtrls.putIfAbsent(
      id.value,
      () {
        final ctrl = StreamController<DeviceState>.broadcast();
        final initial = DeviceState.initial(); // idle
        _lastState[id.value] = initial;
        ctrl.add(initial);
        return ctrl;
      },
    );
  }

  DeviceState _update(DeviceId id, DeviceState newState) {
    _lastState[id.value] = newState;
    _stateCtrl(id).add(newState);
    return newState;
  }

  void startSimScan() {
    if (_scanning) return;
    _scanning = true;
    _scanTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _emitScan(dynamicRssi: true),
    );
  }

  void stopSimScan() {
    _scanning = false;
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  void _emitScan({bool dynamicRssi = false}) {
    final list = _devices
        .map(
          (d) => d.copyWith(
            rssi: dynamicRssi ? d.rssi + _rng.nextInt(5) - 2 : d.rssi,
          ),
        )
        .toList();
    _knownCtrl.add(list);
  }

  @override
  Stream<List<BleDeviceInfo>> known() => _knownCtrl.stream;

  @override
  Future<bool> startScan({Duration timeout = const Duration(seconds: 30)}) async {
    startSimScan();
    if (timeout != Duration.zero) {
      Future.delayed(timeout, () {
        if (_scanning) stopSimScan();
      });
    }
    return true;
  }

  @override
  Future<void> stopScan() async => stopSimScan();

  @override
  bool get isScanning => _scanning;

  @override
  Stream<DeviceState> observe(DeviceId id) => _stateCtrl(id).stream;

  @override
  Future<void> connect(DeviceId id) async {
    _update(
      id,
      const DeviceState(status: DeviceStatus.connecting),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    _update(
      id,
      const DeviceState(status: DeviceStatus.ready),
    );
  }

  @override
  Future<void> disconnect(DeviceId id) async {
    _update(
      id,
      const DeviceState(status: DeviceStatus.disconnected),
    );
  }

  @override
  Future<void> send(DeviceId id, DeviceCommand cmd) async {
    // Mark busy
    final current = _lastState[id.value] ?? DeviceState.initial();
    _update(id, current.copyWith(busy: true));
    await Future.delayed(const Duration(milliseconds: 80));
    // Clear busy (could also mutate other fields depending on cmd)
    final after = _lastState[id.value]!;
    _update(id, after.copyWith(busy: false));
  }

  void dispose() {
    _scanTimer?.cancel();
    for (final c in _stateCtrls.values) {
      c.close();
    }
    _knownCtrl.close();
  }
}