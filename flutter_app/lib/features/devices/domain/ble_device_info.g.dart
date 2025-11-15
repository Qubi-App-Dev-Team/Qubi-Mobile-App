// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BleDeviceInfo _$BleDeviceInfoFromJson(Map<String, dynamic> json) =>
    _BleDeviceInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rssi: (json['rssi'] as num).toInt(),
      discoveredAt: DateTime.parse(json['discoveredAt'] as String),
      lastConnected:
          json['lastConnected'] == null
              ? null
              : DateTime.parse(json['lastConnected'] as String),
    );

Map<String, dynamic> _$BleDeviceInfoToJson(_BleDeviceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'rssi': instance.rssi,
      'discoveredAt': instance.discoveredAt.toIso8601String(),
      'lastConnected': instance.lastConnected?.toIso8601String(),
    };
