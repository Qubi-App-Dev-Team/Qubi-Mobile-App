import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:qubi/features/devices/domain/device_command.dart';
import 'package:qubi/features/devices/domain/device_id.dart';
import 'package:qubi/features/devices/domain/device_state.dart';
import 'package:qubi/features/devices/infrastructure/ble/command_codec.dart';
import 'package:qubi/features/devices/infrastructure/ble/flutter_blue_plus_client.dart';
import 'package:qubi/features/devices/infrastructure/ble/telemetry_mapper.dart';
import 'package:qubi/features/devices/infrastructure/ble/uuids.dart';
import 'package:qubi/features/devices/infrastructure/ble/command_queue.dart';

class DeviceSession {
  final FlutterBluePlusClient fbp;
  final DeviceId id;
  final CommandQueue _queue = CommandQueue();

  final _state = StreamController<DeviceState>.broadcast();
  StreamSubscription<List<int>>? _tempSub;
  StreamSubscription<List<int>>? _batSub;
  BluetoothDevice? _device;
  bool _connected = false;

  DeviceState _snapshot = DeviceState.initial();

  DeviceSession({required this.fbp, required this.id});

  Stream<DeviceState> get state$ => _state.stream;

  Future<void> connect() async {
    if (_connected) return;
    _state.add(_snapshot = _snapshot.copyWith(status: DeviceStatus.connecting));
    _device = fbp.deviceFromId(id.value);
    final dev = _device!;
    if (await dev.connectionState.first != BluetoothConnectionState.connected) {
      await dev.connect(timeout: const Duration(seconds: 10));
    }
    await _subscribe(dev);
  _connected = true;
  _state.add(_snapshot = _snapshot.copyWith(status: DeviceStatus.ready));
  // Start queue pump after connected (fire-and-forget)
  Future(() => _queue.pump((cmd) => _execute(dev, cmd)));
  }

  Future<void> _subscribe(BluetoothDevice dev) async {
    final services = await dev.discoverServices();
    final svc = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase(),
      orElse: () => throw Exception('Qubi service not found'),
    );

    BluetoothCharacteristic charOf(String uuid) => svc.characteristics.firstWhere(
      (c) => c.uuid.toString().toLowerCase() == uuid.toLowerCase(),
      orElse: () => throw Exception('Char not found $uuid'),
    );

    final temp = charOf(QubiUuids.temperatureCharUuid);
    await temp.setNotifyValue(true);
    _tempSub = temp.onValueReceived.listen((d) {
      final t = parseTemperature(d);
      _state.add(_snapshot = _snapshot.copyWith(temperature: t));
    }, onError: _onError, onDone: _onDone);

    final bat = charOf(QubiUuids.batteryCharUuid);
    await bat.setNotifyValue(true);
    _batSub = bat.onValueReceived.listen((d) {
      final b = parseBattery(d);
      _state.add(_snapshot = _snapshot.copyWith(battery: b));
    }, onError: _onError, onDone: _onDone);
  }

  Future<void> enqueue(DeviceCommand cmd) async {
    _state.add(_snapshot = _snapshot.copyWith(busy: true));
    _queue.add(cmd);
  }

  Future<void> _execute(BluetoothDevice dev, DeviceCommand cmd) async {
    final services = await dev.discoverServices();
    final svc = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase(),
      orElse: () => throw Exception('Qubi service not found'),
    );
    final target = cmd.map(
      deepSleep: (_) => QubiUuids.deepSleepCharUuid,
      toggleCharging: (_) => QubiUuids.toggleChargingCharUuid,
      gate: (_) => QubiUuids.gateCharUuid,
      radius: (_) => QubiUuids.radiusCharUuid,
      opacity: (_) => QubiUuids.opacityCharUuid,
      color: (_) => QubiUuids.colorCharUuid,
      theta: (_) => QubiUuids.thetaCharUuid,
      phi: (_) => QubiUuids.phiCharUuid,
      otaControl: (_) => QubiUuids.otaControlCharUuid,
      otaData: (_) => QubiUuids.otaDataCharUuid,
    );
    final ch = svc.characteristics.firstWhere(
      (c) => c.uuid.toString().toLowerCase() == target.toLowerCase(),
    );
    final withoutResp = cmd.maybeMap(
      otaControl: (_) => true,
      otaData: (_) => true,
      orElse: () => false,
    );
    await ch.write(encodeCommand(cmd), withoutResponse: withoutResp);
    _state.add(_snapshot = _snapshot.copyWith(busy: false));
  }

  void _onError(Object e, [StackTrace? _]) {
    _state.add(_snapshot = _snapshot.copyWith(status: DeviceStatus.error, error: e.toString()));
  }

  void _onDone() {
    _connected = false;
    _state.add(_snapshot = _snapshot.copyWith(status: DeviceStatus.disconnected));
  }

  Future<void> dispose() async {
    await _tempSub?.cancel();
    await _batSub?.cancel();
    await _queue.dispose();
    await _device?.disconnect();
    await _state.close();
  }
}
