import 'dart:typed_data';

double parseTemperature(List<int> data) {
  if (data.length >= 4) {
    final b = Uint8List.fromList(data.take(4).toList());
    return b.buffer.asByteData().getFloat32(0, Endian.little);
  }
  return 0.0;
}

int parseBattery(List<int> data) => (data.isNotEmpty ? data.first : 0).clamp(0, 100);
