import 'dart:async';

import 'package:qubi/features/devices/domain/device_command.dart';
import 'package:qubi/features/devices/domain/device_id.dart';
import 'package:qubi/features/devices/domain/device_state.dart';
import 'package:qubi/features/devices/domain/ble_device_info.dart';
import 'package:qubi/features/devices/infrastructure/ble/device_session.dart';
import 'package:qubi/features/devices/infrastructure/ble/device_scanner.dart';
import 'package:qubi/features/devices/infrastructure/ble/flutter_blue_plus_client.dart';
import 'package:qubi/features/devices/infrastructure/repositories/devices_repository_ble_interface.dart';



class DevicesRepositoryBle implements IDevicesRepository {
	final FlutterBluePlusClient fbp;
	final DeviceScanner scanner;
	final _sessions = <String, DeviceSession>{};

	DevicesRepositoryBle({required this.fbp, required this.scanner});

	DeviceSession _s(DeviceId id) =>
			_sessions.putIfAbsent(id.value, () => DeviceSession(fbp: fbp, id: id));

	@override
	Stream<DeviceState> observe(DeviceId id) => _s(id).state$;

	@override
	Future<void> connect(DeviceId id) => _s(id).connect();

	@override
	Future<void> disconnect(DeviceId id) async {
		await _sessions.remove(id.value)?.dispose();
	}

	@override
	Future<void> send(DeviceId id, DeviceCommand cmd) => _s(id).enqueue(cmd);

	@override
	Stream<List<BleDeviceInfo>> known() => scanner.devices$;

	// New scanning API (unified with simulation repo)
	@override
	Future<bool> startScan({Duration timeout = const Duration(seconds: 30)}) => scanner.start(timeout: timeout);

	@override
	Future<void> stopScan() => scanner.stop();

	@override
	bool get isScanning => scanner.isScanning;
}

