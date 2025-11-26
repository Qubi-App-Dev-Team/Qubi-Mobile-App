import 'package:freezed_annotation/freezed_annotation.dart';

part 'ble_device_info.freezed.dart';
part 'ble_device_info.g.dart';

@freezed
sealed class BleDeviceInfo with _$BleDeviceInfo {
  const factory BleDeviceInfo({
    required String id,
    required String name,
    required String address,
    required int rssi,
    required DateTime discoveredAt,
    DateTime? lastConnected,
  }) = _BleDeviceInfo;

  factory BleDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$BleDeviceInfoFromJson(json);
}