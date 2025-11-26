import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qubi/features/devices/infrastructure/ble/uuids.dart';
import '../domain/ble_device_info.dart';

class BleService {
  static BleService? _instance;
 

  BleService._();
  
  static BleService get instance {
    _instance ??= BleService._();
    return _instance!;
  }
  
  // Stream for discovered devices
  final StreamController<List<BleDeviceInfo>> _discoveredDevicesController =
      StreamController<List<BleDeviceInfo>>.broadcast();
  
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream =>
      _discoveredDevicesController.stream;
  
  final List<BleDeviceInfo> _discoveredDevices = [];
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  
  // Temperature notifications
  final StreamController<Map<String, double>> _temperatureController =
      StreamController<Map<String, double>>.broadcast();
  
  Stream<Map<String, double>> get temperatureStream =>
      _temperatureController.stream;
  
  final Map<String, double> _deviceTemperatures = {};
  
  // Battery notifications
  final StreamController<Map<String, int>> _batteryController =
      StreamController<Map<String, int>>.broadcast();
  
  Stream<Map<String, int>> get batteryStream =>
      _batteryController.stream;
  
  final Map<String, int> _deviceBatteries = {};
  
  // Check if Bluetooth is available and enabled
  Future<bool> isBluetoothAvailable() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        return false;
      }
      
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }
  
  // Request necessary permissions
  Future<bool> requestPermissions() async {
    // On macOS, permissions are handled by the system when BLE is first accessed
    // The NSBluetoothAlwaysAndWhenInUseUsageDescription in Info.plist will trigger the permission dialog
    if (Platform.isMacOS) {
      return true; // macOS handles permissions automatically
    }
    
    try {
      // Request location permission (required for BLE scanning on Android/iOS)
      final locationStatus = await Permission.locationWhenInUse.request();
      
      // Request Bluetooth permissions for Android 12+
      final bluetoothScanStatus = await Permission.bluetoothScan.request();
      final bluetoothConnectStatus = await Permission.bluetoothConnect.request();
      
      return locationStatus.isGranted &&
          bluetoothScanStatus.isGranted &&
          bluetoothConnectStatus.isGranted;
    } catch (e) {
      // Fallback for older Android versions
      try {
        final locationStatus = await Permission.locationWhenInUse.request();
        return locationStatus.isGranted;
      } catch (e) {
        // If permission_handler fails entirely, assume permissions are handled by the system
        return true;
      }
    }
  }
  
  // Start scanning for BLE devices
  Future<bool> startScanning({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isScanning) {
      return true;
    }
    
    // Check permissions and Bluetooth state
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      return false;
    }
    
    final isAvailable = await isBluetoothAvailable();
    if (!isAvailable) {
      return false;
    }
    
    try {
      _isScanning = true;
      _discoveredDevices.clear();
      
      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [Guid.fromString(QubiUuids.qubiServiceUuid)],
        withNames: [], // Scan for all device names
      );
      
      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _updateDiscoveredDevices(results);
      });
      
      return true;
    } catch (e) {
      _isScanning = false;
      return false;
    }
  }
  
  // Stop scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _isScanning = false;
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Update discovered devices list
  void _updateDiscoveredDevices(List<ScanResult> scanResults) {
    for (final result in scanResults) {
      final deviceName = result.device.platformName.isNotEmpty
          ? result.device.platformName
          : result.advertisementData.localName.isNotEmpty
              ? result.advertisementData.localName
              : 'Unknown Device';
      
      final deviceInfo = BleDeviceInfo(
        id: result.device.remoteId.toString(),
        name: deviceName,
        address: result.device.remoteId.toString(),
        rssi: result.rssi,
        discoveredAt: DateTime.now(),
      );
      
      // Update existing device or add new one
      final existingIndex = _discoveredDevices.indexWhere(
        (device) => device.id == deviceInfo.id,
      );
      
      if (existingIndex != -1) {
        _discoveredDevices[existingIndex] = deviceInfo;
      } else {
        _discoveredDevices.add(deviceInfo);
      }
    }
    
    // Sort by RSSI (signal strength) - stronger signals first
    _discoveredDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
    
    // Notify listeners
    _discoveredDevicesController.add(List.from(_discoveredDevices));
  }
  
  // Get current scanning state
  bool get isScanning => _isScanning;
  
  // Get list of discovered devices
  List<BleDeviceInfo> get discoveredDevices => List.from(_discoveredDevices);
  
  // Connect to a device (basic implementation)
  Future<bool> connectToDevice(String deviceId) async {
    try {
      // This is a basic implementation - you can expand this
      // to handle actual connection logic based on your needs
      return true;
    } catch (e) {
      return false;
    }
  }

  // Write deep sleep command to device
  Future<bool> writeDeepSleep(String deviceId, bool value) async {
    try {
      // Find the device by ID - create BluetoothDevice from string ID
      final device = BluetoothDevice.fromId(deviceId);
      
      // Check if device is connected
      if (await device.connectionState.first != BluetoothConnectionState.connected) {
        // Try to connect
        await device.connect(timeout: const Duration(seconds: 10));
      }
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find the Qubi service
      BluetoothService? qubiService;
      for (final service in services) {
  if (service.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase()) {
          qubiService = service;
          break;
        }
      }
      
      if (qubiService == null) {
        throw Exception('Qubi service not found');
      }
      
      // Find the deep sleep characteristic
      BluetoothCharacteristic? deepSleepChar;
      for (final characteristic in qubiService.characteristics) {
  if (characteristic.uuid.toString().toLowerCase() == QubiUuids.deepSleepCharUuid.toLowerCase()) {
          deepSleepChar = characteristic;
          break;
        }
      }
      
      if (deepSleepChar == null) {
        throw Exception('Deep sleep characteristic not found');
      }
      
      // Write the boolean value (1 for true, 0 for false)
      final data = [value ? 1 : 0];
      await deepSleepChar.write(data);
      
      return true;
    } catch (e) {
      print('Error writing deep sleep: $e');
      return false;
    }
  }

  // Write toggle charging command to device
  Future<bool> writeToggleCharging(String deviceId, bool value) async {
    try {
      // Find the device by ID - create BluetoothDevice from string ID
      final device = BluetoothDevice.fromId(deviceId);
      
      // Check if device is connected
      if (await device.connectionState.first != BluetoothConnectionState.connected) {
        // Try to connect
        await device.connect(timeout: const Duration(seconds: 10));
      }
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find the Qubi service
      BluetoothService? qubiService;
      for (final service in services) {
  if (service.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase()) {
          qubiService = service;
          break;
        }
      }
      
      if (qubiService == null) {
        throw Exception('Qubi service not found');
      }
      
      // Find the toggle charging characteristic
      BluetoothCharacteristic? toggleChargingChar;
      for (final characteristic in qubiService.characteristics) {
  if (characteristic.uuid.toString().toLowerCase() == QubiUuids.toggleChargingCharUuid.toLowerCase()) {
          toggleChargingChar = characteristic;
          break;
        }
      }
      
      if (toggleChargingChar == null) {
        throw Exception('Toggle charging characteristic not found');
      }
      
      // Write the boolean value (1 for true, 0 for false)
      final data = [value ? 1 : 0];
      await toggleChargingChar.write(data);
      
      return true;
    } catch (e) {
      print('Error writing toggle charging: $e');
      return false;
    }
  }
  
  // Subscribe to temperature notifications from a device
  Future<bool> subscribeToTemperature(String deviceId) async {
    try {
      // Find the device by ID - create BluetoothDevice from string ID
      final device = BluetoothDevice.fromId(deviceId);
      
      // Check if device is connected
      if (await device.connectionState.first != BluetoothConnectionState.connected) {
        // Try to connect
        await device.connect(timeout: const Duration(seconds: 10));
      }
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find the Qubi service
      BluetoothService? qubiService;
      for (final service in services) {
  if (service.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase()) {
          qubiService = service;
          break;
        }
      }
      
      if (qubiService == null) {
        throw Exception('Qubi service not found');
      }
      
      // Find the temperature characteristic
      BluetoothCharacteristic? temperatureChar;
      for (final characteristic in qubiService.characteristics) {
  if (characteristic.uuid.toString().toLowerCase() == QubiUuids.temperatureCharUuid.toLowerCase()) {
          temperatureChar = characteristic;
          break;
        }
      }
      
      if (temperatureChar == null) {
        throw Exception('Temperature characteristic not found');
      }
      
      // Subscribe to notifications
      await temperatureChar.setNotifyValue(true);
      
      // Listen to value changes
      temperatureChar.onValueReceived.listen((data) {
        if (data.isNotEmpty) {
          // Convert bytes to temperature (assuming float format)
          double temperature = 0.0;
          if (data.length >= 4) {
            // Convert 4 bytes to float (little endian)
            final bytes = Uint8List.fromList(data.take(4).toList());
            final buffer = bytes.buffer.asByteData();
            temperature = buffer.getFloat32(0, Endian.little);
          }
          
          // Update temperature map
          _deviceTemperatures[deviceId] = temperature;
          
          // Notify listeners
          _temperatureController.add(Map.from(_deviceTemperatures));
        }
      });
      
      return true;
    } catch (e) {
      print('Error subscribing to temperature: $e');
      return false;
    }
  }
  
  // Get current temperature for a device
  double? getTemperature(String deviceId) {
    return _deviceTemperatures[deviceId];
  }

  // Subscribe to battery notifications from a device
  Future<bool> subscribeToBattery(String deviceId) async {
    try {
      // Find the device by ID - create BluetoothDevice from string ID
      final device = BluetoothDevice.fromId(deviceId);
      
      // Check if device is connected
      if (await device.connectionState.first != BluetoothConnectionState.connected) {
        // Try to connect
        await device.connect(timeout: const Duration(seconds: 10));
      }
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find the Qubi service
      BluetoothService? qubiService;
      for (final service in services) {
  if (service.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase()) {
          qubiService = service;
          break;
        }
      }
      
      if (qubiService == null) {
        throw Exception('Qubi service not found');
      }
      
      // Find the battery characteristic
      BluetoothCharacteristic? batteryChar;
      for (final characteristic in qubiService.characteristics) {
  if (characteristic.uuid.toString().toLowerCase() == QubiUuids.batteryCharUuid.toLowerCase()) {
          batteryChar = characteristic;
          break;
        }
      }
      
      if (batteryChar == null) {
        throw Exception('Battery characteristic not found');
      }
      
      // Subscribe to notifications
      await batteryChar.setNotifyValue(true);
      
      // Listen to value changes
      batteryChar.onValueReceived.listen((data) {
        if (data.isNotEmpty) {
          // Convert byte to battery percentage (assuming single byte 0-100)
          int batteryPercentage = data.first.clamp(0, 100);
          
          // Update battery map
          _deviceBatteries[deviceId] = batteryPercentage;
          
          // Notify listeners
          _batteryController.add(Map.from(_deviceBatteries));
        }
      });
      
      return true;
    } catch (e) {
      print('Error subscribing to battery: $e');
      return false;
    }
  }
  
  // Get current battery for a device
  int? getBattery(String deviceId) {
    return _deviceBatteries[deviceId];
  }

  // Write gate command to device
  Future<bool> writeGateCommand(String deviceId, int gateValue) async {
    try {
      // Find the device by ID - create BluetoothDevice from string ID
      final device = BluetoothDevice.fromId(deviceId);
      
      // Check if device is connected
      if (await device.connectionState.first != BluetoothConnectionState.connected) {
        // Try to connect
        await device.connect(timeout: const Duration(seconds: 10));
      }
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find the Qubi service
      BluetoothService? qubiService;
      for (final service in services) {
  if (service.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase()) {
          qubiService = service;
          break;
        }
      }
      
      if (qubiService == null) {
        throw Exception('Qubi service not found');
      }
      
      // Find the gate characteristic
      BluetoothCharacteristic? gateChar;
      for (final characteristic in qubiService.characteristics) {
  if (characteristic.uuid.toString().toLowerCase() == QubiUuids.gateCharUuid.toLowerCase()) {
          gateChar = characteristic;
          break;
        }
      }
      
      if (gateChar == null) {
        throw Exception('Gate characteristic not found');
      }
      
      // Write the 8-bit gate value (clamped to 0-255)
      final data = [gateValue.clamp(0, 255)];
      await gateChar.write(data);
      
      return true;
    } catch (e) {
      print('Error writing gate command: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    stopScanning();
    _discoveredDevicesController.close();
    _temperatureController.close();
    _batteryController.close();
  }
} 