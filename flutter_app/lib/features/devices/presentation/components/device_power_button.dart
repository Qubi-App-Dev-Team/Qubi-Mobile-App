import 'package:flutter/material.dart';
import 'package:qubi/dependency_injection.dart';
import '../../services/devices_service.dart';
import '../../domain/ble_device_info.dart';

class DevicePowerButton extends StatelessWidget {
  const DevicePowerButton({super.key, required this.device});

  final BleDeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final devicesService = getIt<DevicesService>();
    return IconButton(
      onPressed: () async {
        try {
          await devicesService.deepSleep(device.id, true);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${device.name} turned off successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      icon: Icon(
        Icons.power_settings_new,
        color: Theme.of(context).colorScheme.error,
        size: 20,
      ),
      tooltip: 'Turn Off Device',
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        padding: const EdgeInsets.all(4),
        minimumSize: const Size(32, 32),
      ),
    );
  }
}
