import 'package:flutter/material.dart';

/// A small glassy-style connection indicator with a glowing dot and label.
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({
    super.key,
    required this.connected,
    this.label = 'Connected',
    this.showWhenDisconnected = false,
  });

  final bool connected;
  final String label;
  /// If false (default), the widget returns an empty SizedBox when not connected.
  final bool showWhenDisconnected;

  @override
  Widget build(BuildContext context) {
    if (!connected && !showWhenDisconnected) return const SizedBox.shrink();

    final Color dotColor = connected
        ? const Color(0xFF6DE9C7)
        : Theme.of(context).colorScheme.error.withOpacity(0.75);

    final String effectiveLabel = connected ? label : 'Disconnected';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
            decoration: BoxDecoration(
            color: dotColor.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          effectiveLabel,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
              ),
        ),
      ],
    );
  }
}
