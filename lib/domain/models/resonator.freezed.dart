// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resonator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Resonator {

 String get id; String get name; int get stars; Attribute get attribute; Weapon get weapon; String get iconAsset; String get portraitAsset; List<Stat> get usableStats;@JsonKey(includeIfNull: false) EchoSet? get savedEchoSet; List<String> get teams;
/// Create a copy of Resonator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResonatorCopyWith<Resonator> get copyWith => _$ResonatorCopyWithImpl<Resonator>(this as Resonator, _$identity);

  /// Serializes this Resonator to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Resonator&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.attribute, attribute) || other.attribute == attribute)&&(identical(other.weapon, weapon) || other.weapon == weapon)&&(identical(other.iconAsset, iconAsset) || other.iconAsset == iconAsset)&&(identical(other.portraitAsset, portraitAsset) || other.portraitAsset == portraitAsset)&&const DeepCollectionEquality().equals(other.usableStats, usableStats)&&(identical(other.savedEchoSet, savedEchoSet) || other.savedEchoSet == savedEchoSet)&&const DeepCollectionEquality().equals(other.teams, teams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,stars,attribute,weapon,iconAsset,portraitAsset,const DeepCollectionEquality().hash(usableStats),savedEchoSet,const DeepCollectionEquality().hash(teams));

@override
String toString() {
  return 'Resonator(id: $id, name: $name, stars: $stars, attribute: $attribute, weapon: $weapon, iconAsset: $iconAsset, portraitAsset: $portraitAsset, usableStats: $usableStats, savedEchoSet: $savedEchoSet, teams: $teams)';
}


}

/// @nodoc
abstract mixin class $ResonatorCopyWith<$Res>  {
  factory $ResonatorCopyWith(Resonator value, $Res Function(Resonator) _then) = _$ResonatorCopyWithImpl;
@useResult
$Res call({
 String id, String name, int stars, Attribute attribute, Weapon weapon, String iconAsset, String portraitAsset, List<Stat> usableStats,@JsonKey(includeIfNull: false) EchoSet? savedEchoSet, List<String> teams
});


$EchoSetCopyWith<$Res>? get savedEchoSet;

}
/// @nodoc
class _$ResonatorCopyWithImpl<$Res>
    implements $ResonatorCopyWith<$Res> {
  _$ResonatorCopyWithImpl(this._self, this._then);

  final Resonator _self;
  final $Res Function(Resonator) _then;

/// Create a copy of Resonator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? stars = null,Object? attribute = null,Object? weapon = null,Object? iconAsset = null,Object? portraitAsset = null,Object? usableStats = null,Object? savedEchoSet = freezed,Object? teams = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,attribute: null == attribute ? _self.attribute : attribute // ignore: cast_nullable_to_non_nullable
as Attribute,weapon: null == weapon ? _self.weapon : weapon // ignore: cast_nullable_to_non_nullable
as Weapon,iconAsset: null == iconAsset ? _self.iconAsset : iconAsset // ignore: cast_nullable_to_non_nullable
as String,portraitAsset: null == portraitAsset ? _self.portraitAsset : portraitAsset // ignore: cast_nullable_to_non_nullable
as String,usableStats: null == usableStats ? _self.usableStats : usableStats // ignore: cast_nullable_to_non_nullable
as List<Stat>,savedEchoSet: freezed == savedEchoSet ? _self.savedEchoSet : savedEchoSet // ignore: cast_nullable_to_non_nullable
as EchoSet?,teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Resonator
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EchoSetCopyWith<$Res>? get savedEchoSet {
    if (_self.savedEchoSet == null) {
    return null;
  }

  return $EchoSetCopyWith<$Res>(_self.savedEchoSet!, (value) {
    return _then(_self.copyWith(savedEchoSet: value));
  });
}
}


/// Adds pattern-matching-related methods to [Resonator].
extension ResonatorPatterns on Resonator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Resonator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Resonator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Resonator value)  $default,){
final _that = this;
switch (_that) {
case _Resonator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Resonator value)?  $default,){
final _that = this;
switch (_that) {
case _Resonator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int stars,  Attribute attribute,  Weapon weapon,  String iconAsset,  String portraitAsset,  List<Stat> usableStats, @JsonKey(includeIfNull: false)  EchoSet? savedEchoSet,  List<String> teams)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Resonator() when $default != null:
return $default(_that.id,_that.name,_that.stars,_that.attribute,_that.weapon,_that.iconAsset,_that.portraitAsset,_that.usableStats,_that.savedEchoSet,_that.teams);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int stars,  Attribute attribute,  Weapon weapon,  String iconAsset,  String portraitAsset,  List<Stat> usableStats, @JsonKey(includeIfNull: false)  EchoSet? savedEchoSet,  List<String> teams)  $default,) {final _that = this;
switch (_that) {
case _Resonator():
return $default(_that.id,_that.name,_that.stars,_that.attribute,_that.weapon,_that.iconAsset,_that.portraitAsset,_that.usableStats,_that.savedEchoSet,_that.teams);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int stars,  Attribute attribute,  Weapon weapon,  String iconAsset,  String portraitAsset,  List<Stat> usableStats, @JsonKey(includeIfNull: false)  EchoSet? savedEchoSet,  List<String> teams)?  $default,) {final _that = this;
switch (_that) {
case _Resonator() when $default != null:
return $default(_that.id,_that.name,_that.stars,_that.attribute,_that.weapon,_that.iconAsset,_that.portraitAsset,_that.usableStats,_that.savedEchoSet,_that.teams);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Resonator extends Resonator {
  const _Resonator({required this.id, required this.name, this.stars = 5, required this.attribute, required this.weapon, required this.iconAsset, required this.portraitAsset, final  List<Stat> usableStats = const [], @JsonKey(includeIfNull: false) this.savedEchoSet, final  List<String> teams = const []}): _usableStats = usableStats,_teams = teams,super._();
  factory _Resonator.fromJson(Map<String, dynamic> json) => _$ResonatorFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  int stars;
@override final  Attribute attribute;
@override final  Weapon weapon;
@override final  String iconAsset;
@override final  String portraitAsset;
 final  List<Stat> _usableStats;
@override@JsonKey() List<Stat> get usableStats {
  if (_usableStats is EqualUnmodifiableListView) return _usableStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usableStats);
}

@override@JsonKey(includeIfNull: false) final  EchoSet? savedEchoSet;
 final  List<String> _teams;
@override@JsonKey() List<String> get teams {
  if (_teams is EqualUnmodifiableListView) return _teams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teams);
}


/// Create a copy of Resonator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResonatorCopyWith<_Resonator> get copyWith => __$ResonatorCopyWithImpl<_Resonator>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResonatorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Resonator&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.attribute, attribute) || other.attribute == attribute)&&(identical(other.weapon, weapon) || other.weapon == weapon)&&(identical(other.iconAsset, iconAsset) || other.iconAsset == iconAsset)&&(identical(other.portraitAsset, portraitAsset) || other.portraitAsset == portraitAsset)&&const DeepCollectionEquality().equals(other._usableStats, _usableStats)&&(identical(other.savedEchoSet, savedEchoSet) || other.savedEchoSet == savedEchoSet)&&const DeepCollectionEquality().equals(other._teams, _teams));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,stars,attribute,weapon,iconAsset,portraitAsset,const DeepCollectionEquality().hash(_usableStats),savedEchoSet,const DeepCollectionEquality().hash(_teams));

@override
String toString() {
  return 'Resonator(id: $id, name: $name, stars: $stars, attribute: $attribute, weapon: $weapon, iconAsset: $iconAsset, portraitAsset: $portraitAsset, usableStats: $usableStats, savedEchoSet: $savedEchoSet, teams: $teams)';
}


}

/// @nodoc
abstract mixin class _$ResonatorCopyWith<$Res> implements $ResonatorCopyWith<$Res> {
  factory _$ResonatorCopyWith(_Resonator value, $Res Function(_Resonator) _then) = __$ResonatorCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int stars, Attribute attribute, Weapon weapon, String iconAsset, String portraitAsset, List<Stat> usableStats,@JsonKey(includeIfNull: false) EchoSet? savedEchoSet, List<String> teams
});


@override $EchoSetCopyWith<$Res>? get savedEchoSet;

}
/// @nodoc
class __$ResonatorCopyWithImpl<$Res>
    implements _$ResonatorCopyWith<$Res> {
  __$ResonatorCopyWithImpl(this._self, this._then);

  final _Resonator _self;
  final $Res Function(_Resonator) _then;

/// Create a copy of Resonator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? stars = null,Object? attribute = null,Object? weapon = null,Object? iconAsset = null,Object? portraitAsset = null,Object? usableStats = null,Object? savedEchoSet = freezed,Object? teams = null,}) {
  return _then(_Resonator(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,attribute: null == attribute ? _self.attribute : attribute // ignore: cast_nullable_to_non_nullable
as Attribute,weapon: null == weapon ? _self.weapon : weapon // ignore: cast_nullable_to_non_nullable
as Weapon,iconAsset: null == iconAsset ? _self.iconAsset : iconAsset // ignore: cast_nullable_to_non_nullable
as String,portraitAsset: null == portraitAsset ? _self.portraitAsset : portraitAsset // ignore: cast_nullable_to_non_nullable
as String,usableStats: null == usableStats ? _self._usableStats : usableStats // ignore: cast_nullable_to_non_nullable
as List<Stat>,savedEchoSet: freezed == savedEchoSet ? _self.savedEchoSet : savedEchoSet // ignore: cast_nullable_to_non_nullable
as EchoSet?,teams: null == teams ? _self._teams : teams // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Resonator
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EchoSetCopyWith<$Res>? get savedEchoSet {
    if (_self.savedEchoSet == null) {
    return null;
  }

  return $EchoSetCopyWith<$Res>(_self.savedEchoSet!, (value) {
    return _then(_self.copyWith(savedEchoSet: value));
  });
}
}

// dart format on
