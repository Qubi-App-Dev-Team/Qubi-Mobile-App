import 'package:flutter/material.dart';
import 'dart:ui';
import '../../domain/ble_device_info.dart';
import 'device_info_block.dart';
import 'device_status_block.dart';
import 'device_power_button.dart';
import 'device_options_menu.dart';
import 'gates_component.dart';
import 'action_tile_button.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.temperature,
    required this.battery,
    required this.onGate,
    required this.onToggleCharging,
    required this.onPlaceholder,
    required this.onRemove,
    required this.onOpenSettings,
  });

  final BleDeviceInfo device;
  final double? temperature;
  final int? battery;
  final void Function(BleDeviceInfo device, int gateValue, String gateName) onGate;
  final void Function(BleDeviceInfo device) onToggleCharging;
  final void Function(String label, BleDeviceInfo device) onPlaceholder;
  final void Function(BleDeviceInfo device) onRemove;
  final void Function(BleDeviceInfo device) onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Stronger crisp white border
              border: Border.all(color: Colors.white.withAlpha(200), width: 1.2),
              // Translucent glass gradient with subtle depth tint
              
              // Layered shadows: outer ambient + inner glow
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha(80),
                  blurRadius: 6,
                  spreadRadius: -2,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top info row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeviceInfoBlock(device: device),
                    const SizedBox(width: 16),
                    DeviceStatusBlock(
                      device: device,
                      temperature: temperature,
                      battery: battery,
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        // ConnectionStatusIndicator(
                        //   connected: temperature != null || battery != null,
                        // ),
                        // if (temperature != null || battery != null)
                        //   const SizedBox(height: 12),
                        DevicePowerButton(device: device),
                        const SizedBox(height: 8),
                        DeviceOptionsMenu(
                          device: device,
                          onRemove: onRemove,
                          onOpenSettings: onOpenSettings,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Primary gates - responsive grid (adapts columns based on width)
                GatesComponent(
                  device: device,
                  onGate: onGate,
                ),
                const SizedBox(height: 14),
                // Action tiles - horizontally scrollable responsive
                SizedBox(
                  height: 80,
                  child: _ScrollArrowsListView(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    separatorWidth: 8,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      const double tileWidth = 72;
                      final actions = <Widget>[
                        ActionTileButton(
                          icon: Icons.monitor_heart,
                          label: 'Measure',
                          onTap: () => onGate(device, 11, 'Measure'),
                        ),
                        ActionTileButton(
                          icon: Icons.battery_charging_full,
                          label: 'Toggle\nCharging',
                          onTap: () => onToggleCharging(device),
                        ),
                        ActionTileButton(
                          icon: Icons.radio_button_checked,
                          label: 'Button\nPress',
                          onTap: () => onPlaceholder('Button press', device),
                        ),
                        ActionTileButton(
                          icon: Icons.medical_services_outlined,
                          label: 'Procedure\nMode',
                          onTap: () => onPlaceholder('Procedure mode', device),
                        ),
                        ActionTileButton(
                          icon: Icons.sensors,
                          label: 'Record\nGyro',
                          onTap: () => onPlaceholder('Record gyro', device),
                        ),
                        ActionTileButton(
                          icon: Icons.restart_alt,
                          label: 'Reset',
                          onTap: () => onPlaceholder('Reset', device),
                        ),
                      ];
                      return SizedBox(width: tileWidth, child: actions[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable horizontally scrollable list with fading arrow indicators when overflow exists.
class _ScrollArrowsListView extends StatefulWidget {
  const _ScrollArrowsListView({
    required this.itemBuilder,
    required this.itemCount,
    required this.height,
    this.padding,
    this.separatorWidth = 0,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double separatorWidth;

  @override
  State<_ScrollArrowsListView> createState() => _ScrollArrowsListViewState();
}

class _ScrollArrowsListViewState extends State<_ScrollArrowsListView> {
  late final ScrollController _controller;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_updateArrowVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  void _evaluate() {
    if (!mounted || !_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    setState(() {
      _initialized = true;
      _canScrollLeft = _controller.offset > 0;
      _canScrollRight = max > 0 && _controller.offset < max;
    });
  }

  void _updateArrowVisibility() {
    if (!mounted || !_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final left = _controller.offset > 2;
    final right = _controller.offset < (max - 2);
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  void _scrollBy(double delta) {
    if (!_controller.hasClients) return;
    final target = (_controller.offset + delta).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateArrowVisibility);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < widget.itemCount; i++) {
      children.add(widget.itemBuilder(context, i));
      if (i != widget.itemCount - 1 && widget.separatorWidth > 0) {
        children.add(SizedBox(width: widget.separatorWidth));
      }
    }

    final list = ListView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: widget.padding,
      children: children,
    );

    final showArrows = _initialized && (_canScrollLeft || _canScrollRight);

    return Stack(
      fit: StackFit.expand,
      children: [
        list,
        if (showArrows)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Row(
                children: [
                  _ArrowOverlay(
                    visible: _canScrollLeft,
                    icon: Icons.chevron_left,
                    alignment: Alignment.centerLeft,
                    onTap: () => _scrollBy(-120),
                  ),
                  const Spacer(),
                  _ArrowOverlay(
                    visible: _canScrollRight,
                    icon: Icons.chevron_right,
                    alignment: Alignment.centerRight,
                    onTap: () => _scrollBy(120),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ArrowOverlay extends StatelessWidget {
  const _ArrowOverlay({
    required this.visible,
    required this.icon,
    required this.alignment,
    required this.onTap,
  });

  final bool visible;
  final IconData icon;
  final Alignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Align(
          alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(icon, size: 18, color: Colors.black87),
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }
}
