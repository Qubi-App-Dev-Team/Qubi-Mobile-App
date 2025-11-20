import 'dart:typed_data';

import 'package:qubi/features/devices/domain/device_command.dart';

List<int> encodeCommand(DeviceCommand cmd) {
  return cmd.when(
    deepSleep: (v) => [v ? 1 : 0],
    toggleCharging: (v) => [v ? 1 : 0],
    gate: (n) => [_clamp8(n)],
    radius: (v) => _f32le(v),
    opacity: (v) => _f32le(v),
    color: (r, g, b) => [_clamp8(r), _clamp8(g), _clamp8(b)],
    theta: (rad) => _f32le(rad),
    phi: (rad) => _f32le(rad),
    otaControl: (data) => List<int>.from(data),
    otaData: (data) => List<int>.from(data),
  );
}

int _clamp8(num n) => n.clamp(0, 255).toInt();

List<int> _f32le(double v) {
  final bd = ByteData(4)..setFloat32(0, v, Endian.little);
  return bd.buffer.asUint8List();
}
