import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_state.freezed.dart';

enum DeviceStatus { idle, connecting, ready, disconnected, error }

@freezed
sealed class DeviceState with _$DeviceState {
  const factory DeviceState({
    @Default(DeviceStatus.idle) DeviceStatus status,
    @Default(false) bool busy,
    @Default(0) int battery,
    @Default(0.0) double temperature,
    String? error,
  }) = _DeviceState;

  const DeviceState._();

  factory DeviceState.initial() => const DeviceState();
}
