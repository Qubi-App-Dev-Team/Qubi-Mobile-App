// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceCommand {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceCommand);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeviceCommand()';
}


}

/// @nodoc
class $DeviceCommandCopyWith<$Res>  {
$DeviceCommandCopyWith(DeviceCommand _, $Res Function(DeviceCommand) __);
}


/// Adds pattern-matching-related methods to [DeviceCommand].
extension DeviceCommandPatterns on DeviceCommand {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DeepSleepCommand value)?  deepSleep,TResult Function( ToggleChargingCommand value)?  toggleCharging,TResult Function( GateCommand value)?  gate,TResult Function( RadiusCommand value)?  radius,TResult Function( OpacityCommand value)?  opacity,TResult Function( ColorCommand value)?  color,TResult Function( ThetaCommand value)?  theta,TResult Function( PhiCommand value)?  phi,TResult Function( OtaControlCommand value)?  otaControl,TResult Function( OtaDataCommand value)?  otaData,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DeepSleepCommand() when deepSleep != null:
return deepSleep(_that);case ToggleChargingCommand() when toggleCharging != null:
return toggleCharging(_that);case GateCommand() when gate != null:
return gate(_that);case RadiusCommand() when radius != null:
return radius(_that);case OpacityCommand() when opacity != null:
return opacity(_that);case ColorCommand() when color != null:
return color(_that);case ThetaCommand() when theta != null:
return theta(_that);case PhiCommand() when phi != null:
return phi(_that);case OtaControlCommand() when otaControl != null:
return otaControl(_that);case OtaDataCommand() when otaData != null:
return otaData(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DeepSleepCommand value)  deepSleep,required TResult Function( ToggleChargingCommand value)  toggleCharging,required TResult Function( GateCommand value)  gate,required TResult Function( RadiusCommand value)  radius,required TResult Function( OpacityCommand value)  opacity,required TResult Function( ColorCommand value)  color,required TResult Function( ThetaCommand value)  theta,required TResult Function( PhiCommand value)  phi,required TResult Function( OtaControlCommand value)  otaControl,required TResult Function( OtaDataCommand value)  otaData,}){
final _that = this;
switch (_that) {
case DeepSleepCommand():
return deepSleep(_that);case ToggleChargingCommand():
return toggleCharging(_that);case GateCommand():
return gate(_that);case RadiusCommand():
return radius(_that);case OpacityCommand():
return opacity(_that);case ColorCommand():
return color(_that);case ThetaCommand():
return theta(_that);case PhiCommand():
return phi(_that);case OtaControlCommand():
return otaControl(_that);case OtaDataCommand():
return otaData(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DeepSleepCommand value)?  deepSleep,TResult? Function( ToggleChargingCommand value)?  toggleCharging,TResult? Function( GateCommand value)?  gate,TResult? Function( RadiusCommand value)?  radius,TResult? Function( OpacityCommand value)?  opacity,TResult? Function( ColorCommand value)?  color,TResult? Function( ThetaCommand value)?  theta,TResult? Function( PhiCommand value)?  phi,TResult? Function( OtaControlCommand value)?  otaControl,TResult? Function( OtaDataCommand value)?  otaData,}){
final _that = this;
switch (_that) {
case DeepSleepCommand() when deepSleep != null:
return deepSleep(_that);case ToggleChargingCommand() when toggleCharging != null:
return toggleCharging(_that);case GateCommand() when gate != null:
return gate(_that);case RadiusCommand() when radius != null:
return radius(_that);case OpacityCommand() when opacity != null:
return opacity(_that);case ColorCommand() when color != null:
return color(_that);case ThetaCommand() when theta != null:
return theta(_that);case PhiCommand() when phi != null:
return phi(_that);case OtaControlCommand() when otaControl != null:
return otaControl(_that);case OtaDataCommand() when otaData != null:
return otaData(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool enabled)?  deepSleep,TResult Function( bool enabled)?  toggleCharging,TResult Function( int value)?  gate,TResult Function( double value)?  radius,TResult Function( double value)?  opacity,TResult Function( int r,  int g,  int b)?  color,TResult Function( double radians)?  theta,TResult Function( double radians)?  phi,TResult Function( List<int> data)?  otaControl,TResult Function( List<int> data)?  otaData,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DeepSleepCommand() when deepSleep != null:
return deepSleep(_that.enabled);case ToggleChargingCommand() when toggleCharging != null:
return toggleCharging(_that.enabled);case GateCommand() when gate != null:
return gate(_that.value);case RadiusCommand() when radius != null:
return radius(_that.value);case OpacityCommand() when opacity != null:
return opacity(_that.value);case ColorCommand() when color != null:
return color(_that.r,_that.g,_that.b);case ThetaCommand() when theta != null:
return theta(_that.radians);case PhiCommand() when phi != null:
return phi(_that.radians);case OtaControlCommand() when otaControl != null:
return otaControl(_that.data);case OtaDataCommand() when otaData != null:
return otaData(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool enabled)  deepSleep,required TResult Function( bool enabled)  toggleCharging,required TResult Function( int value)  gate,required TResult Function( double value)  radius,required TResult Function( double value)  opacity,required TResult Function( int r,  int g,  int b)  color,required TResult Function( double radians)  theta,required TResult Function( double radians)  phi,required TResult Function( List<int> data)  otaControl,required TResult Function( List<int> data)  otaData,}) {final _that = this;
switch (_that) {
case DeepSleepCommand():
return deepSleep(_that.enabled);case ToggleChargingCommand():
return toggleCharging(_that.enabled);case GateCommand():
return gate(_that.value);case RadiusCommand():
return radius(_that.value);case OpacityCommand():
return opacity(_that.value);case ColorCommand():
return color(_that.r,_that.g,_that.b);case ThetaCommand():
return theta(_that.radians);case PhiCommand():
return phi(_that.radians);case OtaControlCommand():
return otaControl(_that.data);case OtaDataCommand():
return otaData(_that.data);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool enabled)?  deepSleep,TResult? Function( bool enabled)?  toggleCharging,TResult? Function( int value)?  gate,TResult? Function( double value)?  radius,TResult? Function( double value)?  opacity,TResult? Function( int r,  int g,  int b)?  color,TResult? Function( double radians)?  theta,TResult? Function( double radians)?  phi,TResult? Function( List<int> data)?  otaControl,TResult? Function( List<int> data)?  otaData,}) {final _that = this;
switch (_that) {
case DeepSleepCommand() when deepSleep != null:
return deepSleep(_that.enabled);case ToggleChargingCommand() when toggleCharging != null:
return toggleCharging(_that.enabled);case GateCommand() when gate != null:
return gate(_that.value);case RadiusCommand() when radius != null:
return radius(_that.value);case OpacityCommand() when opacity != null:
return opacity(_that.value);case ColorCommand() when color != null:
return color(_that.r,_that.g,_that.b);case ThetaCommand() when theta != null:
return theta(_that.radians);case PhiCommand() when phi != null:
return phi(_that.radians);case OtaControlCommand() when otaControl != null:
return otaControl(_that.data);case OtaDataCommand() when otaData != null:
return otaData(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class DeepSleepCommand implements DeviceCommand {
  const DeepSleepCommand(this.enabled);
  

 final  bool enabled;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeepSleepCommandCopyWith<DeepSleepCommand> get copyWith => _$DeepSleepCommandCopyWithImpl<DeepSleepCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepSleepCommand&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'DeviceCommand.deepSleep(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $DeepSleepCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $DeepSleepCommandCopyWith(DeepSleepCommand value, $Res Function(DeepSleepCommand) _then) = _$DeepSleepCommandCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$DeepSleepCommandCopyWithImpl<$Res>
    implements $DeepSleepCommandCopyWith<$Res> {
  _$DeepSleepCommandCopyWithImpl(this._self, this._then);

  final DeepSleepCommand _self;
  final $Res Function(DeepSleepCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(DeepSleepCommand(
null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ToggleChargingCommand implements DeviceCommand {
  const ToggleChargingCommand(this.enabled);
  

 final  bool enabled;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleChargingCommandCopyWith<ToggleChargingCommand> get copyWith => _$ToggleChargingCommandCopyWithImpl<ToggleChargingCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleChargingCommand&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'DeviceCommand.toggleCharging(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $ToggleChargingCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $ToggleChargingCommandCopyWith(ToggleChargingCommand value, $Res Function(ToggleChargingCommand) _then) = _$ToggleChargingCommandCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$ToggleChargingCommandCopyWithImpl<$Res>
    implements $ToggleChargingCommandCopyWith<$Res> {
  _$ToggleChargingCommandCopyWithImpl(this._self, this._then);

  final ToggleChargingCommand _self;
  final $Res Function(ToggleChargingCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(ToggleChargingCommand(
null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class GateCommand implements DeviceCommand {
  const GateCommand(this.value);
  

 final  int value;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GateCommandCopyWith<GateCommand> get copyWith => _$GateCommandCopyWithImpl<GateCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GateCommand&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'DeviceCommand.gate(value: $value)';
}


}

/// @nodoc
abstract mixin class $GateCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $GateCommandCopyWith(GateCommand value, $Res Function(GateCommand) _then) = _$GateCommandCopyWithImpl;
@useResult
$Res call({
 int value
});




}
/// @nodoc
class _$GateCommandCopyWithImpl<$Res>
    implements $GateCommandCopyWith<$Res> {
  _$GateCommandCopyWithImpl(this._self, this._then);

  final GateCommand _self;
  final $Res Function(GateCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(GateCommand(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class RadiusCommand implements DeviceCommand {
  const RadiusCommand(this.value);
  

 final  double value;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadiusCommandCopyWith<RadiusCommand> get copyWith => _$RadiusCommandCopyWithImpl<RadiusCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadiusCommand&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'DeviceCommand.radius(value: $value)';
}


}

/// @nodoc
abstract mixin class $RadiusCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $RadiusCommandCopyWith(RadiusCommand value, $Res Function(RadiusCommand) _then) = _$RadiusCommandCopyWithImpl;
@useResult
$Res call({
 double value
});




}
/// @nodoc
class _$RadiusCommandCopyWithImpl<$Res>
    implements $RadiusCommandCopyWith<$Res> {
  _$RadiusCommandCopyWithImpl(this._self, this._then);

  final RadiusCommand _self;
  final $Res Function(RadiusCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(RadiusCommand(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class OpacityCommand implements DeviceCommand {
  const OpacityCommand(this.value);
  

 final  double value;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpacityCommandCopyWith<OpacityCommand> get copyWith => _$OpacityCommandCopyWithImpl<OpacityCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpacityCommand&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'DeviceCommand.opacity(value: $value)';
}


}

/// @nodoc
abstract mixin class $OpacityCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $OpacityCommandCopyWith(OpacityCommand value, $Res Function(OpacityCommand) _then) = _$OpacityCommandCopyWithImpl;
@useResult
$Res call({
 double value
});




}
/// @nodoc
class _$OpacityCommandCopyWithImpl<$Res>
    implements $OpacityCommandCopyWith<$Res> {
  _$OpacityCommandCopyWithImpl(this._self, this._then);

  final OpacityCommand _self;
  final $Res Function(OpacityCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(OpacityCommand(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class ColorCommand implements DeviceCommand {
  const ColorCommand(this.r, this.g, this.b);
  

 final  int r;
 final  int g;
 final  int b;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorCommandCopyWith<ColorCommand> get copyWith => _$ColorCommandCopyWithImpl<ColorCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorCommand&&(identical(other.r, r) || other.r == r)&&(identical(other.g, g) || other.g == g)&&(identical(other.b, b) || other.b == b));
}


@override
int get hashCode => Object.hash(runtimeType,r,g,b);

@override
String toString() {
  return 'DeviceCommand.color(r: $r, g: $g, b: $b)';
}


}

/// @nodoc
abstract mixin class $ColorCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $ColorCommandCopyWith(ColorCommand value, $Res Function(ColorCommand) _then) = _$ColorCommandCopyWithImpl;
@useResult
$Res call({
 int r, int g, int b
});




}
/// @nodoc
class _$ColorCommandCopyWithImpl<$Res>
    implements $ColorCommandCopyWith<$Res> {
  _$ColorCommandCopyWithImpl(this._self, this._then);

  final ColorCommand _self;
  final $Res Function(ColorCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? r = null,Object? g = null,Object? b = null,}) {
  return _then(ColorCommand(
null == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as int,null == g ? _self.g : g // ignore: cast_nullable_to_non_nullable
as int,null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ThetaCommand implements DeviceCommand {
  const ThetaCommand(this.radians);
  

 final  double radians;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThetaCommandCopyWith<ThetaCommand> get copyWith => _$ThetaCommandCopyWithImpl<ThetaCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThetaCommand&&(identical(other.radians, radians) || other.radians == radians));
}


@override
int get hashCode => Object.hash(runtimeType,radians);

@override
String toString() {
  return 'DeviceCommand.theta(radians: $radians)';
}


}

/// @nodoc
abstract mixin class $ThetaCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $ThetaCommandCopyWith(ThetaCommand value, $Res Function(ThetaCommand) _then) = _$ThetaCommandCopyWithImpl;
@useResult
$Res call({
 double radians
});




}
/// @nodoc
class _$ThetaCommandCopyWithImpl<$Res>
    implements $ThetaCommandCopyWith<$Res> {
  _$ThetaCommandCopyWithImpl(this._self, this._then);

  final ThetaCommand _self;
  final $Res Function(ThetaCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? radians = null,}) {
  return _then(ThetaCommand(
null == radians ? _self.radians : radians // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class PhiCommand implements DeviceCommand {
  const PhiCommand(this.radians);
  

 final  double radians;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhiCommandCopyWith<PhiCommand> get copyWith => _$PhiCommandCopyWithImpl<PhiCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhiCommand&&(identical(other.radians, radians) || other.radians == radians));
}


@override
int get hashCode => Object.hash(runtimeType,radians);

@override
String toString() {
  return 'DeviceCommand.phi(radians: $radians)';
}


}

/// @nodoc
abstract mixin class $PhiCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $PhiCommandCopyWith(PhiCommand value, $Res Function(PhiCommand) _then) = _$PhiCommandCopyWithImpl;
@useResult
$Res call({
 double radians
});




}
/// @nodoc
class _$PhiCommandCopyWithImpl<$Res>
    implements $PhiCommandCopyWith<$Res> {
  _$PhiCommandCopyWithImpl(this._self, this._then);

  final PhiCommand _self;
  final $Res Function(PhiCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? radians = null,}) {
  return _then(PhiCommand(
null == radians ? _self.radians : radians // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class OtaControlCommand implements DeviceCommand {
  const OtaControlCommand(final  List<int> data): _data = data;
  

 final  List<int> _data;
 List<int> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtaControlCommandCopyWith<OtaControlCommand> get copyWith => _$OtaControlCommandCopyWithImpl<OtaControlCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtaControlCommand&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'DeviceCommand.otaControl(data: $data)';
}


}

/// @nodoc
abstract mixin class $OtaControlCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $OtaControlCommandCopyWith(OtaControlCommand value, $Res Function(OtaControlCommand) _then) = _$OtaControlCommandCopyWithImpl;
@useResult
$Res call({
 List<int> data
});




}
/// @nodoc
class _$OtaControlCommandCopyWithImpl<$Res>
    implements $OtaControlCommandCopyWith<$Res> {
  _$OtaControlCommandCopyWithImpl(this._self, this._then);

  final OtaControlCommand _self;
  final $Res Function(OtaControlCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(OtaControlCommand(
null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc


class OtaDataCommand implements DeviceCommand {
  const OtaDataCommand(final  List<int> data): _data = data;
  

 final  List<int> _data;
 List<int> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtaDataCommandCopyWith<OtaDataCommand> get copyWith => _$OtaDataCommandCopyWithImpl<OtaDataCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtaDataCommand&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'DeviceCommand.otaData(data: $data)';
}


}

/// @nodoc
abstract mixin class $OtaDataCommandCopyWith<$Res> implements $DeviceCommandCopyWith<$Res> {
  factory $OtaDataCommandCopyWith(OtaDataCommand value, $Res Function(OtaDataCommand) _then) = _$OtaDataCommandCopyWithImpl;
@useResult
$Res call({
 List<int> data
});




}
/// @nodoc
class _$OtaDataCommandCopyWithImpl<$Res>
    implements $OtaDataCommandCopyWith<$Res> {
  _$OtaDataCommandCopyWithImpl(this._self, this._then);

  final OtaDataCommand _self;
  final $Res Function(OtaDataCommand) _then;

/// Create a copy of DeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(OtaDataCommand(
null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
