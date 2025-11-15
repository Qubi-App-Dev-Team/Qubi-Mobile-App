import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qubi/core/theme/app_theme.dart';
import 'package:qubi/dependency_injection.dart';
import '../domain/ble_device_info.dart';
import '../services/device_storage_service.dart';
import '../services/devices_service.dart';
import 'ble_scan_screen.dart';
import 'device_settings_screen.dart';
import 'components/device_card.dart';
import 'components/no_devices_placeholder.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DeviceStorageService _storageService = DeviceStorageService.instance;
  final DevicesService _devicesService = getIt<DevicesService>();
  List<BleDeviceInfo> _savedDevices = [];
  bool _isLoading = true;
  Map<String, double> _deviceTemperatures = {};
  Map<String, int> _deviceBatteries = {};
  final Map<String, StreamSubscription> _stateSubscriptions = {};

  @override
  void initState() {
    super.initState();
    _loadSavedDevices();
  // Per-device subscriptions are established after loading saved devices.
  }

  @override
  void dispose() {
    for (final sub in _stateSubscriptions.values) {
      sub.cancel();
    }
    _stateSubscriptions.clear();
    super.dispose();
  }

  void _subscribeToDeviceState(String deviceId) {
    if (_stateSubscriptions.containsKey(deviceId)) return;
    _devicesService.connect(deviceId);
    final sub = _devicesService.observe(deviceId).listen((s) {
      if (!mounted) return;
      setState(() {
        _deviceTemperatures = {
          ..._deviceTemperatures,
          deviceId: s.temperature,
        };
        _deviceBatteries = {
          ..._deviceBatteries,
          deviceId: s.battery,
        };
      });
    });
    _stateSubscriptions[deviceId] = sub;
  }

  Future<void> _loadSavedDevices() async {
    try {
      final devices = await _storageService.getSavedDevices();
      if (mounted) {
        setState(() {
          _savedDevices = devices;
          _isLoading = false;
        });
        
        // Subscribe to per-device state updates
        for (final device in devices) {
          _subscribeToDeviceState(device.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading devices: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _subscribeToDeviceTemperature(String deviceId) async {
    _subscribeToDeviceState(deviceId);
  }

  Future<void> _subscribeToDeviceBattery(String deviceId) async {
    _subscribeToDeviceState(deviceId);
  }

  // Helper method to send gate commands
  Future<void> _sendGateCommand(BleDeviceInfo device, int gateValue, String gateName) async {
    try {
      await _devicesService.gate(device.id, gateValue);
      if (mounted) {
        // Optional success UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Helper method for toggle charging
  Future<void> _handleToggleCharging(BleDeviceInfo device) async {
    try {
      await _devicesService.toggleCharging(device.id, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} charging toggled successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Helper method for placeholder buttons
  void _showPlaceholderMessage(String label, BleDeviceInfo device) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label pressed on ${device.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _openScanScreen() async {
    final result = await Navigator.of(context).push<BleDeviceInfo>(
      MaterialPageRoute(
        builder: (context) => const BleScanScreen(),
      ),
    );

    // If a device was selected, refresh the devices list
    if (result != null) {
      await _loadSavedDevices();
      
  // Subscribe to state updates for the new device
  await _subscribeToDeviceTemperature(result.id);
  await _subscribeToDeviceBattery(result.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device "${result.name}" added successfully!'),
            backgroundColor: AppColors.emberOrange,
          ),
        );
      }
    }
  }

  Future<void> _removeDevice(BleDeviceInfo device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text('Are you sure you want to remove "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _storageService.removeDevice(device.id);
        await _loadSavedDevices();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Device "${device.name}" removed.'),
              backgroundColor: AppColors.emberOrange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing device: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _openDeviceSettings(BleDeviceInfo device) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceSettingsScreen(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x22FF4D4D),
            Color(0x22FFB84D),
            Color(0x22FFFF80),
            Color(0x224DFF4D),
            Color(0x224D4DFF),
            Color(0x226666CC),
            Color(0x22994D99),
          ],
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Devices'),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.45),
                    Colors.white.withOpacity(0.12),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.35),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (_savedDevices.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllDevices();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20),
                      SizedBox(width: 12),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedDevices.isEmpty
              ? const NoDevicesPlaceholder()
              : ScrollConfiguration(
                  behavior: const _DesktopScrollBehavior(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    itemCount: _savedDevices.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final double topPad = MediaQuery.of(context).padding.top;
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(16, topPad, 16, 8),
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registered Devices',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_savedDevices.length} device${_savedDevices.length == 1 ? '' : 's'} found',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        );
                      }
                      final d = _savedDevices[index - 1];
                      return DeviceCard(
                        device: d,
                        temperature: _deviceTemperatures[d.id],
                        battery: _deviceBatteries[d.id],
                        onGate: (device, gateValue, gateName) => _sendGateCommand(device, gateValue, gateName),
                        onToggleCharging: _handleToggleCharging,
                        onPlaceholder: _showPlaceholderMessage,
                        onRemove: _removeDevice,
                        onOpenSettings: _openDeviceSettings,
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openScanScreen,
        tooltip: 'Scan for Devices',
        child: const Icon(Icons.add),
      ),
    ),
    );
  }

  Future<void> _clearAllDevices() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Devices'),
        content: const Text('Are you sure you want to remove all devices?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _storageService.clearAllDevices();
        await _loadSavedDevices();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All devices removed.'),
              backgroundColor: AppColors.emberOrange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing devices: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
} 

// Enables dragging with mouse & trackpad on desktop (macOS) for ListView.
class _DesktopScrollBehavior extends ScrollBehavior {
  const _DesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}