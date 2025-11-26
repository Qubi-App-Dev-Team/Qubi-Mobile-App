import 'dart:async';

import 'package:qubi/features/devices/domain/device_command.dart';

class CommandQueue {
  final _q = StreamController<DeviceCommand>(sync: true);
  bool _busy = false;

  void add(DeviceCommand c) => _q.add(c);

  Future<void> pump(Future<void> Function(DeviceCommand) exec) async {
    if (_busy) return;
    _busy = true;
    try {
      await for (final c in _q.stream) {
        await _withRetry(() => exec(c));
      }
    } finally { _busy = false; }
  }

  Future<void> _withRetry(Future<void> Function() run) async {
    for (var a = 1; a <= 3; a++) {
      try { await run(); return; }
      catch (_) { await Future.delayed(Duration(milliseconds: 150 * a)); }
    }
    throw Exception('Command failed after 3 retries');
  }

  Future<void> dispose() async { await _q.close(); }
}
