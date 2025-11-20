import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FlutterBluePlusClient {
  FlutterBluePlusClient();

  Future<bool> isAdapterOn() async {
    if (await FlutterBluePlus.isSupported == false) return false;
    return (await FlutterBluePlus.adapterState.first) == BluetoothAdapterState.on;
  }

  Future<void> startScan({required List<Guid> services, Duration? timeout}) =>
      FlutterBluePlus.startScan(withServices: services, timeout: timeout);

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  BluetoothDevice deviceFromId(String id) => BluetoothDevice.fromId(id);
}
