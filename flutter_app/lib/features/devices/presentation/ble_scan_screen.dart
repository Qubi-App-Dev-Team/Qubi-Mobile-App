import 'package:flutter/material.dart';
import 'package:qubi/dependency_injection.dart';
import 'dart:async';
import '../domain/ble_device_info.dart';
import '../services/devices_service.dart';
import '../services/device_storage_service.dart';

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  final DevicesService _bleService = getIt<DevicesService>();
  final DeviceStorageService _storageService = DeviceStorageService.instance;
  
  List<BleDeviceInfo> _discoveredDevices = [];
  bool _isScanning = false;
  String? _errorMessage;
  StreamSubscription<List<BleDeviceInfo>>? _devicesSubscription;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _scanTimer?.cancel();
    _bleService.stopScanning();
    super.dispose();
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _discoveredDevices.clear();
    });

    // Listen to discovered devices
  _devicesSubscription = _bleService.devices$.listen(
      (devices) {
        if (mounted) {
          setState(() {
            _discoveredDevices = devices;
          });
        }
      },
    );

    // Start scanning
    final success = await _bleService.startScanning();
    
    if (!success) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Failed to start scanning. Please check Bluetooth permissions and ensure Bluetooth is enabled.';
        });
      }
      return;
    }

    // Auto-stop scanning after 30 seconds
    _scanTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _stopScanning();
      }
    });
  }

  Future<void> _stopScanning() async {
    await _bleService.stopScanning();
    _scanTimer?.cancel();
    
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _selectDevice(BleDeviceInfo device) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Adding device...'),
          ],
        ),
      ),
    );

    try {
      // Save device to storage
      await _storageService.saveDevice(device);
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Return to devices screen with the selected device
        Navigator.of(context).pop(device);
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add device: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildDeviceCard(BleDeviceInfo device) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        title: Text(
          device.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address: ${device.address}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Signal: ${device.rssi} dBm',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: _getSignalColor(device.rssi),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: () => _selectDevice(device),
      ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -50) {
      return Colors.green;
    } else if (rssi > -70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for Qubis'),
        actions: [
          if (_isScanning)
            IconButton(
              onPressed: _stopScanning,
              icon: const Icon(Icons.stop),
              tooltip: 'Stop Scanning',
            )
          else
            IconButton(
              onPressed: _startScanning,
              icon: const Icon(Icons.refresh),
              tooltip: 'Start Scanning',
            ),
        ],
      ),
      body: Column(
        children: [
          // Scanning status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isScanning
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Row(
              children: [
                if (_isScanning) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scanning...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ] else if (_errorMessage != null) ...[
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.bluetooth_searching,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scan completed. ${_discoveredDevices.length} devices found.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Devices list
          Expanded(
            child: _discoveredDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Looking for Qubis...'
                              : _errorMessage != null
                                  ? 'No Qubis found'
                                  : 'No Qubis found',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (!_isScanning && _errorMessage == null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap the refresh button to scan again',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _discoveredDevices.length,
                    itemBuilder: (context, index) {
                      return _buildDeviceCard(_discoveredDevices[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 