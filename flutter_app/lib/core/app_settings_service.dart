// ignore_for_file: non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSettingsService {

  late bool SIMULATE_BLE;
  late bool SCAN_ONLY_QUBI;

  Future<void> init() async {

    String envFileName = '.env';

    await dotenv.load(fileName: envFileName);

    SIMULATE_BLE = dotenv.env['SIMULATE_BLE'] == 'true';
    SCAN_ONLY_QUBI = dotenv.env['SCAN_ONLY_QUBI'] == 'true';
  }
}
