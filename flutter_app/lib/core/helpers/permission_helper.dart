import 'dart:developer';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  Future<bool> ensureBlePermissions() async {
    if (Platform.isIOS || Platform.isMacOS){
      log("[INFO] - [permission_helper.dart] iOS/macOS: relying on system Bluetooth prompt");
      return true;
    }

    //Android:
    PermissionStatus loc = await Permission.locationWhenInUse.request();
    PermissionStatus scan = await Permission.bluetoothScan.request();
    PermissionStatus conn = await Permission.bluetoothConnect.request();
    log(  "[INFO] - [permission_helper.dart] Permissions: "
        "Location=${loc.isGranted}, "
        "Scan=${scan.isGranted}, "
        "Connect=${conn.isGranted}");
    return loc.isGranted && scan.isGranted && conn.isGranted;
  }
}
