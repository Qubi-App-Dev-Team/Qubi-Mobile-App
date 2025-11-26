import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_command.freezed.dart';

@freezed
sealed class DeviceCommand with _$DeviceCommand {
  const factory DeviceCommand.deepSleep(bool enabled) = DeepSleepCommand;
  const factory DeviceCommand.toggleCharging(bool enabled) = ToggleChargingCommand;
  const factory DeviceCommand.gate(int value) = GateCommand;

  const factory DeviceCommand.radius(double value) = RadiusCommand;
  const factory DeviceCommand.opacity(double value) = OpacityCommand;
  const factory DeviceCommand.color(int r, int g, int b) = ColorCommand;
  const factory DeviceCommand.theta(double radians) = ThetaCommand;
  const factory DeviceCommand.phi(double radians) = PhiCommand;

  // Over-the-Air (OTA) update commands
  const factory DeviceCommand.otaControl(List<int> data) = OtaControlCommand;
  const factory DeviceCommand.otaData(List<int> data) = OtaDataCommand;
}
