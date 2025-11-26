import 'package:flutter/material.dart';
import '../../domain/ble_device_info.dart';
import 'control_button.dart';

class GatesComponent extends StatelessWidget {
  const GatesComponent({
    super.key,
    required this.device,
    required this.onGate,
  });

  final BleDeviceInfo device;
  final void Function(BleDeviceInfo device, int gateValue, String gateName) onGate;

  @override
  Widget build(BuildContext context) {
    final buttons = const [
      ('X', 1),
      ('Y', 2),
      ('Z', 3),
      ('T', 7),
      ('T*dag', 8),
      ('H', 4),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Target a compact tile width; scale columns to available width.
        const targetTileWidth = 92.0; // includes padding/margins
        final maxWidth = constraints.maxWidth;
        var columns = (maxWidth / targetTileWidth).floor();
        columns = columns.clamp(2, buttons.length); // between 2 and full set

        // Keep rows compact by using a wide aspect ratio (w/h)
        final childAspectRatio = 3.2; // wider than tall buttons

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 8,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: buttons.length,
          itemBuilder: (context, i) {
            final (label, value) = buttons[i];
            return ControlButton(
              label: label,
              onPressed: () => onGate(device, value, label),
              expanded: false,
              width: double.infinity,
            );
          },
        );
      },
    );
  }
}
