import 'package:qubi/features/devices/domain/ble_device_info.dart';
import 'package:qubi/features/devices/domain/device_command.dart';
import 'package:qubi/features/devices/domain/device_id.dart';
import 'package:qubi/features/devices/domain/device_state.dart';

abstract class IDevicesRepository {
	// Scanning
	Future<bool> startScan({Duration timeout});
	Future<void> stopScan();
	bool get isScanning;
	Stream<List<BleDeviceInfo>> known();

	// Device sessions / commands
	Stream<DeviceState> observe(DeviceId id);
	Future<void> connect(DeviceId id);
	Future<void> disconnect(DeviceId id);
	Future<void> send(DeviceId id, DeviceCommand cmd);
}