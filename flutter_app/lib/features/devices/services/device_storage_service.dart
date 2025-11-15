import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ble_device_info.dart';

class DeviceStorageService {
  static const String _devicesKey = 'saved_ble_devices';
  
  static DeviceStorageService? _instance;
  SharedPreferences? _prefs;
  
  DeviceStorageService._();
  
  static DeviceStorageService get instance {
    _instance ??= DeviceStorageService._();
    return _instance!;
  }
  
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  Future<List<BleDeviceInfo>> getSavedDevices() async {
    await init();
    final devicesJson = _prefs?.getStringList(_devicesKey) ?? [];
    
    return devicesJson
        .map((deviceString) {
          try {
            final deviceMap = jsonDecode(deviceString) as Map<String, dynamic>;
            return BleDeviceInfo.fromJson(deviceMap);
          } catch (e) {
            // Skip invalid device data
            return null;
          }
        })
        .where((device) => device != null)
        .cast<BleDeviceInfo>()
        .toList();
  }
  
  Future<bool> saveDevice(BleDeviceInfo device) async {
    await init();
    final savedDevices = await getSavedDevices();
    
    // Remove existing device with same ID if present
    savedDevices.removeWhere((d) => d.id == device.id);
    
    // Add the new/updated device
    savedDevices.add(device);
    
    // Convert to JSON strings
    final devicesJson = savedDevices
        .map((device) => jsonEncode(device.toJson()))
        .toList();
    
    return await _prefs?.setStringList(_devicesKey, devicesJson) ?? false;
  }
  
  Future<bool> removeDevice(String deviceId) async {
    await init();
    final savedDevices = await getSavedDevices();
    
    // Remove device with matching ID
    savedDevices.removeWhere((device) => device.id == deviceId);
    
    // Convert to JSON strings
    final devicesJson = savedDevices
        .map((device) => jsonEncode(device.toJson()))
        .toList();
    
    return await _prefs?.setStringList(_devicesKey, devicesJson) ?? false;
  }
  
  Future<bool> clearAllDevices() async {
    await init();
    return await _prefs?.remove(_devicesKey) ?? false;
  }
  
  Future<BleDeviceInfo?> getDevice(String deviceId) async {
    final savedDevices = await getSavedDevices();
    try {
      return savedDevices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }
} 