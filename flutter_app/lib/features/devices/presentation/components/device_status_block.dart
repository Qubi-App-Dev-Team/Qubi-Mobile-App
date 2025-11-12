import 'package:flutter/material.dart';
import '../../domain/ble_device_info.dart';
import 'package:qubi/core/theme/app_theme.dart';

class DeviceStatusBlock extends StatelessWidget {
  const DeviceStatusBlock({
    super.key,
    required this.device,
    required this.temperature,
    required this.battery,
  });

  final BleDeviceInfo device;
  final double? temperature;
  final int? battery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.thermostat,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${(temperature ?? 0.0).toStringAsFixed(2)}°F',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.battery_3_bar,
                size: 16,
                color: AppColors.ionGreen,
              ),
              const SizedBox(width: 4),
              Text(
                '${battery ?? 0}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
