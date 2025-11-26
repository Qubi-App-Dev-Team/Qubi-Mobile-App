import 'package:flutter/material.dart';
import '../../domain/ble_device_info.dart';

class DeviceOptionsMenu extends StatelessWidget {
  const DeviceOptionsMenu({
    super.key,
    required this.device,
    required this.onRemove,
    required this.onOpenSettings,
  });

  final BleDeviceInfo device;
  final void Function(BleDeviceInfo device) onRemove;
  final void Function(BleDeviceInfo device) onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'remove') {
          onRemove(device);
        } else if (value == 'settings') {
          onOpenSettings(device);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'settings',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 8),
              Text('Remove'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.more_vert,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
