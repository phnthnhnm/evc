// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'echo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Echo {

 Map<String, double> get stats; double get score; String get tier;
/// Create a copy of Echo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EchoCopyWith<Echo> get copyWith => _$EchoCopyWithImpl<Echo>(this as Echo, _$identity);

  /// Serializes this Echo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Echo&&const DeepCollectionEquality().equals(other.stats, stats)&&(identical(other.score, score) || other.score == score)&&(identical(other.tier, tier) || other.tier == tier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(stats),score,tier);

@override
String toString() {
  return 'Echo(stats: $stats, score: $score, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $EchoCopyWith<$Res>  {
  factory $EchoCopyWith(Echo value, $Res Function(Echo) _then) = _$EchoCopyWithImpl;
@useResult
$Res call({
 Map<String, double> stats, double score, String tier
});




}
/// @nodoc
class _$EchoCopyWithImpl<$Res>
    implements $EchoCopyWith<$Res> {
  _$EchoCopyWithImpl(this._self, this._then);

  final Echo _self;
  final $Res Function(Echo) _then;

/// Create a copy of Echo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stats = null,Object? score = null,Object? tier = null,}) {
  return _then(_self.copyWith(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, double>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Echo].
extension EchoPatterns on Echo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Echo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Echo() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Echo value)  $default,){
final _that = this;
switch (_that) {
case _Echo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Echo value)?  $default,){
final _that = this;
switch (_that) {
case _Echo() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, double> stats,  double score,  String tier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Echo() when $default != null:
return $default(_that.stats,_that.score,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, double> stats,  double score,  String tier)  $default,) {final _that = this;
switch (_that) {
case _Echo():
return $default(_that.stats,_that.score,_that.tier);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, double> stats,  double score,  String tier)?  $default,) {final _that = this;
switch (_that) {
case _Echo() when $default != null:
return $default(_that.stats,_that.score,_that.tier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Echo implements Echo {
  const _Echo({final  Map<String, double> stats = const {}, this.score = 0.0, this.tier = 'Unbuilt'}): _stats = stats;
  factory _Echo.fromJson(Map<String, dynamic> json) => _$EchoFromJson(json);

 final  Map<String, double> _stats;
@override@JsonKey() Map<String, double> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

@override@JsonKey() final  double score;
@override@JsonKey() final  String tier;

/// Create a copy of Echo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EchoCopyWith<_Echo> get copyWith => __$EchoCopyWithImpl<_Echo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EchoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Echo&&const DeepCollectionEquality().equals(other._stats, _stats)&&(identical(other.score, score) || other.score == score)&&(identical(other.tier, tier) || other.tier == tier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_stats),score,tier);

@override
String toString() {
  return 'Echo(stats: $stats, score: $score, tier: $tier)';
}


}

/// @nodoc
abstract mixin class _$EchoCopyWith<$Res> implements $EchoCopyWith<$Res> {
  factory _$EchoCopyWith(_Echo value, $Res Function(_Echo) _then) = __$EchoCopyWithImpl;
@override @useResult
$Res call({
 Map<String, double> stats, double score, String tier
});




}
/// @nodoc
class __$EchoCopyWithImpl<$Res>
    implements _$EchoCopyWith<$Res> {
  __$EchoCopyWithImpl(this._self, this._then);

  final _Echo _self;
  final $Res Function(_Echo) _then;

/// Create a copy of Echo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stats = null,Object? score = null,Object? tier = null,}) {
  return _then(_Echo(
stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, double>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
