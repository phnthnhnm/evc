// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'echo_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EchoSet {

@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson) List<Echo> get echoes;@JsonKey(name: 'overallScore') double get overallScore;@JsonKey(name: 'overallTier') String get overallTier;@JsonKey(name: 'totalER') double get totalER; String? get team;
/// Create a copy of EchoSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EchoSetCopyWith<EchoSet> get copyWith => _$EchoSetCopyWithImpl<EchoSet>(this as EchoSet, _$identity);

  /// Serializes this EchoSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EchoSet&&const DeepCollectionEquality().equals(other.echoes, echoes)&&(identical(other.overallScore, overallScore) || other.overallScore == overallScore)&&(identical(other.overallTier, overallTier) || other.overallTier == overallTier)&&(identical(other.totalER, totalER) || other.totalER == totalER)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(echoes),overallScore,overallTier,totalER,team);

@override
String toString() {
  return 'EchoSet(echoes: $echoes, overallScore: $overallScore, overallTier: $overallTier, totalER: $totalER, team: $team)';
}


}

/// @nodoc
abstract mixin class $EchoSetCopyWith<$Res>  {
  factory $EchoSetCopyWith(EchoSet value, $Res Function(EchoSet) _then) = _$EchoSetCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson) List<Echo> echoes,@JsonKey(name: 'overallScore') double overallScore,@JsonKey(name: 'overallTier') String overallTier,@JsonKey(name: 'totalER') double totalER, String? team
});




}
/// @nodoc
class _$EchoSetCopyWithImpl<$Res>
    implements $EchoSetCopyWith<$Res> {
  _$EchoSetCopyWithImpl(this._self, this._then);

  final EchoSet _self;
  final $Res Function(EchoSet) _then;

/// Create a copy of EchoSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? echoes = null,Object? overallScore = null,Object? overallTier = null,Object? totalER = null,Object? team = freezed,}) {
  return _then(_self.copyWith(
echoes: null == echoes ? _self.echoes : echoes // ignore: cast_nullable_to_non_nullable
as List<Echo>,overallScore: null == overallScore ? _self.overallScore : overallScore // ignore: cast_nullable_to_non_nullable
as double,overallTier: null == overallTier ? _self.overallTier : overallTier // ignore: cast_nullable_to_non_nullable
as String,totalER: null == totalER ? _self.totalER : totalER // ignore: cast_nullable_to_non_nullable
as double,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EchoSet].
extension EchoSetPatterns on EchoSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EchoSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EchoSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EchoSet value)  $default,){
final _that = this;
switch (_that) {
case _EchoSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EchoSet value)?  $default,){
final _that = this;
switch (_that) {
case _EchoSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson)  List<Echo> echoes, @JsonKey(name: 'overallScore')  double overallScore, @JsonKey(name: 'overallTier')  String overallTier, @JsonKey(name: 'totalER')  double totalER,  String? team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EchoSet() when $default != null:
return $default(_that.echoes,_that.overallScore,_that.overallTier,_that.totalER,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson)  List<Echo> echoes, @JsonKey(name: 'overallScore')  double overallScore, @JsonKey(name: 'overallTier')  String overallTier, @JsonKey(name: 'totalER')  double totalER,  String? team)  $default,) {final _that = this;
switch (_that) {
case _EchoSet():
return $default(_that.echoes,_that.overallScore,_that.overallTier,_that.totalER,_that.team);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson)  List<Echo> echoes, @JsonKey(name: 'overallScore')  double overallScore, @JsonKey(name: 'overallTier')  String overallTier, @JsonKey(name: 'totalER')  double totalER,  String? team)?  $default,) {final _that = this;
switch (_that) {
case _EchoSet() when $default != null:
return $default(_that.echoes,_that.overallScore,_that.overallTier,_that.totalER,_that.team);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EchoSet implements EchoSet {
  const _EchoSet({@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson) final  List<Echo> echoes = const [], @JsonKey(name: 'overallScore') this.overallScore = 0.0, @JsonKey(name: 'overallTier') this.overallTier = 'Unbuilt', @JsonKey(name: 'totalER') this.totalER = 100.0, this.team}): _echoes = echoes;
  factory _EchoSet.fromJson(Map<String, dynamic> json) => _$EchoSetFromJson(json);

 final  List<Echo> _echoes;
@override@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson) List<Echo> get echoes {
  if (_echoes is EqualUnmodifiableListView) return _echoes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_echoes);
}

@override@JsonKey(name: 'overallScore') final  double overallScore;
@override@JsonKey(name: 'overallTier') final  String overallTier;
@override@JsonKey(name: 'totalER') final  double totalER;
@override final  String? team;

/// Create a copy of EchoSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EchoSetCopyWith<_EchoSet> get copyWith => __$EchoSetCopyWithImpl<_EchoSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EchoSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EchoSet&&const DeepCollectionEquality().equals(other._echoes, _echoes)&&(identical(other.overallScore, overallScore) || other.overallScore == overallScore)&&(identical(other.overallTier, overallTier) || other.overallTier == overallTier)&&(identical(other.totalER, totalER) || other.totalER == totalER)&&(identical(other.team, team) || other.team == team));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_echoes),overallScore,overallTier,totalER,team);

@override
String toString() {
  return 'EchoSet(echoes: $echoes, overallScore: $overallScore, overallTier: $overallTier, totalER: $totalER, team: $team)';
}


}

/// @nodoc
abstract mixin class _$EchoSetCopyWith<$Res> implements $EchoSetCopyWith<$Res> {
  factory _$EchoSetCopyWith(_EchoSet value, $Res Function(_EchoSet) _then) = __$EchoSetCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson) List<Echo> echoes,@JsonKey(name: 'overallScore') double overallScore,@JsonKey(name: 'overallTier') String overallTier,@JsonKey(name: 'totalER') double totalER, String? team
});




}
/// @nodoc
class __$EchoSetCopyWithImpl<$Res>
    implements _$EchoSetCopyWith<$Res> {
  __$EchoSetCopyWithImpl(this._self, this._then);

  final _EchoSet _self;
  final $Res Function(_EchoSet) _then;

/// Create a copy of EchoSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? echoes = null,Object? overallScore = null,Object? overallTier = null,Object? totalER = null,Object? team = freezed,}) {
  return _then(_EchoSet(
echoes: null == echoes ? _self._echoes : echoes // ignore: cast_nullable_to_non_nullable
as List<Echo>,overallScore: null == overallScore ? _self.overallScore : overallScore // ignore: cast_nullable_to_non_nullable
as double,overallTier: null == overallTier ? _self.overallTier : overallTier // ignore: cast_nullable_to_non_nullable
as String,totalER: null == totalER ? _self.totalER : totalER // ignore: cast_nullable_to_non_nullable
as double,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
