import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ota/ota_package.dart';
import 'package:qubi/core/theme/app_theme.dart';
import '../domain/ble_device_info.dart';
import 'package:qubi/features/devices/infrastructure/ble/uuids.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final BleDeviceInfo device;

  const DeviceSettingsScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  // BleService no longer used; OTA uses UUIDs directly
  
  bool _isUpdating = false;
  double _updateProgress = 0.0;
  String _updateStatus = '';
  StreamSubscription<int>? _progressSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Esp32OtaPackage? _otaPackage;
  BluetoothDevice? _connectedDevice;
  
  // Firmware URL updated to actual S3 location
  static const String _firmwareUrl = 'https://qolour-firmware.s3.us-east-2.amazonaws.com/RemoteDisplayIdf-0.3.0.bin';

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  /// Set optimal MTU for better throughput
  Future<int> _setOptimalMtu(BluetoothDevice device) async {
    try {
      // Get current MTU
      int currentMtu = await device.mtu.first;
      
      // Set optimal MTU based on platform
      // Android: 512 bytes, iOS: 247 bytes (due to platform limitations)
      int targetMtu = Platform.isAndroid ? 512 : 247;
      
      setState(() {
        _updateStatus = 'Optimizing connection (MTU: $currentMtu → $targetMtu)...';
      });
      
      // Request MTU change
      int newMtu = await device.requestMtu(targetMtu);
      
      setState(() {
        _updateStatus = 'Connection optimized (MTU: $newMtu bytes)';
      });
      
      // Small delay to ensure MTU change is processed
      await Future.delayed(const Duration(milliseconds: 500));
      
      return newMtu;
    } catch (e) {
      print('Warning: Could not set optimal MTU: $e');
      // Return current MTU if optimization fails
      return await device.mtu.first;
    }
  }

  /// Connect to device with retry logic
  Future<BluetoothDevice> _connectWithRetry(String deviceId, {int maxRetries = 3}) async {
    final device = BluetoothDevice.fromId(deviceId);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        setState(() {
          _updateStatus = 'Connecting to device (attempt $attempt/$maxRetries)...';
        });
        
        // Check current connection state
        final connectionState = await device.connectionState.first;
        
        if (connectionState == BluetoothConnectionState.connected) {
          setState(() {
            _updateStatus = 'Device already connected';
          });
          return device;
        }
        
        // Attempt connection with timeout
        await device.connect(
          timeout: const Duration(seconds: 15),
          autoConnect: false,
        );
        
        // Wait for connection to be established
        await device.connectionState
            .where((state) => state == BluetoothConnectionState.connected)
            .first
            .timeout(const Duration(seconds: 10));
        
        setState(() {
          _updateStatus = 'Connected successfully';
        });
        
        return device;
        
      } catch (e) {
        print('Connection attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          throw Exception('Failed to connect after $maxRetries attempts: $e');
        }
        
        // Progressive backoff delay
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Connection failed');
  }

  /// Monitor connection during update
  void _monitorConnection(BluetoothDevice device) {
    _connectionSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected && _isUpdating) {
        if (mounted) {
          setState(() {
            _isUpdating = false;
            _updateStatus = 'Connection lost during update';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Device disconnected during firmware update'),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: _showUpdateConfirmationDialog,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> _updateFirmware() async {
    setState(() {
      _isUpdating = true;
      _updateProgress = 0.0;
      _updateStatus = 'Initializing firmware update...';
    });

    try {
      // Step 1: Connect to device with retry logic
      _connectedDevice = await _connectWithRetry(widget.device.id);
      
      // Step 2: Monitor connection during update
      _monitorConnection(_connectedDevice!);
      
      // Step 3: Set optimal MTU for better throughput
      final mtuSize = await _setOptimalMtu(_connectedDevice!);
      
      // Step 4: Discover services
      setState(() {
        _updateStatus = 'Discovering device services...';
      });
      
      final services = await _connectedDevice!.discoverServices();
      BluetoothService? qubiService;
      
      for (final service in services) {
  if (service.uuid.toString().toLowerCase() == QubiUuids.qubiServiceUuid.toLowerCase()) {
          qubiService = service;
          break;
        }
      }

      if (qubiService == null) {
        throw Exception('Qubi service not found. Please ensure device firmware supports OTA updates.');
      }

      // Step 5: Find OTA characteristics
      setState(() {
        _updateStatus = 'Locating OTA characteristics...';
      });
      
      BluetoothCharacteristic? otaControlChar;
      BluetoothCharacteristic? otaDataChar;
      
      for (final characteristic in qubiService.characteristics) {
        final charUuid = characteristic.uuid.toString().toLowerCase();
  if (charUuid == QubiUuids.otaControlCharUuid.toLowerCase()) {
          otaControlChar = characteristic;
  } else if (charUuid == QubiUuids.otaDataCharUuid.toLowerCase()) {
          otaDataChar = characteristic;
        }
      }

      if (otaControlChar == null || otaDataChar == null) {
        throw Exception('OTA characteristics not found. Device may not support firmware updates.');
      }

      // Step 6: Create OTA package instance
      setState(() {
        _updateStatus = 'Preparing OTA update (MTU: ${mtuSize}B)...';
      });
      
      _otaPackage = Esp32OtaPackage(otaControlChar, otaDataChar);

      // Step 7: Subscribe to progress updates with enhanced feedback
      _progressSubscription = _otaPackage!.percentageStream.listen((percentage) {
        if (mounted) {
          setState(() {
            _updateProgress = percentage / 100.0;
            if (percentage < 5) {
              _updateStatus = 'Downloading firmware...';
            } else if (percentage < 10) {
              _updateStatus = 'Validating firmware...';
            } else if (percentage < 95) {
              _updateStatus = 'Transferring firmware: ${percentage.toInt()}%';
            } else if (percentage < 100) {
              _updateStatus = 'Finalizing update...';
            } else {
              _updateStatus = 'Update completed!';
            }
          });
        }
      });

      // Step 8: Start firmware update with enhanced parameters
      setState(() {
        _updateStatus = 'Starting firmware transfer...';
      });
      
      await _otaPackage!.updateFirmware(
        _connectedDevice!,
        1, // Update type 1 (ESP-IDF/Espressif)
        3, // Firmware type 3 (URL download)
        qubiService,
        otaDataChar,
        otaControlChar,
        url: _firmwareUrl,
      );

      // Step 9: Handle completion
      if (mounted) {
        final success = _otaPackage!.firmwareUpdate;
        setState(() {
          _isUpdating = false;
          _updateProgress = success ? 1.0 : 0.0;
          _updateStatus = success 
              ? 'Firmware update completed successfully! Device will restart.'
              : 'Firmware update failed. Please try again.';
        });

        // Show completion message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_updateStatus),
            backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
            duration: Duration(seconds: success ? 5 : 3),
            action: success ? null : SnackBarAction(
              label: 'Retry',
              onPressed: _showUpdateConfirmationDialog,
            ),
          ),
        );

        // Auto-close the dialog after successful update
        if (success) {
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
          _updateProgress = 0.0;
          _updateStatus = 'Update failed: ${_getErrorMessage(e.toString())}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_updateStatus),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _showUpdateConfirmationDialog,
            ),
          ),
        );
      }
    } finally {
      _progressSubscription?.cancel();
      _connectionSubscription?.cancel();
    }
  }

  /// Convert technical error messages to user-friendly ones
  String _getErrorMessage(String error) {
    if (error.contains('timeout') || error.contains('Timeout')) {
      return 'Connection timeout. Please move closer to the device.';
    } else if (error.contains('connect') || error.contains('Connect')) {
      return 'Unable to connect to device. Please try again.';
    } else if (error.contains('service not found')) {
      return 'Device does not support firmware updates.';
    } else if (error.contains('characteristics not found')) {
      return 'Device firmware is incompatible with OTA updates.';
    } else if (error.contains('MTU')) {
      return 'Connection optimization failed. Update may be slower.';
    } else {
      return 'Update failed. Please ensure device is powered and nearby.';
    }
  }

  Future<void> _showUpdateConfirmationDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Firmware'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to update the firmware for "${widget.device.name}"?'),
            const SizedBox(height: 16),
            const Text(
              'Warning: Do not disconnect the device during the update process.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Optimizations:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• ${Platform.isAndroid ? "Android" : "iOS"} optimized MTU',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Text(
                    '• Automatic retry on connection loss',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    '• Real-time progress tracking',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricIndigo,
              foregroundColor: AppColors.saltWhite,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _updateFirmware();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.name} Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Name', widget.device.name),
                    _buildInfoRow('Address', widget.device.address),
                    _buildInfoRow('Added', _formatDate(widget.device.discoveredAt)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Firmware Update Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Firmware Management',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (!_isUpdating)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.electricIndigo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.electricIndigo.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed,
                                  size: 14,
                                  color: AppColors.electricIndigo,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Optimized',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.electricIndigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Keep your Qubi device up to date with the latest firmware. Enhanced with platform-optimized MTU settings for faster transfers.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Update Progress (shown during update)
                    if (_isUpdating) ...[
                      Text(
                        _updateStatus,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _updateProgress,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(_updateProgress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_connectedDevice != null)
                            FutureBuilder<int>(
                              future: _connectedDevice!.mtu.first,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    'MTU: ${snapshot.data}B',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : _showUpdateConfirmationDialog,
                        icon: Icon(_isUpdating ? Icons.hourglass_empty : Icons.system_update),
                        label: Text(_isUpdating ? 'Updating...' : 'Update Firmware'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricIndigo,
                          foregroundColor: AppColors.saltWhite,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    if (!_isUpdating && _updateStatus.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _updateStatus.contains('successfully') 
                              ? Colors.green.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _updateStatus.contains('successfully') 
                                ? Colors.green.withValues(alpha: 0.3)
                                : Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _updateStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _updateStatus.contains('successfully') 
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}