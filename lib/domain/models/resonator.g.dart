// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resonator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Resonator _$ResonatorFromJson(Map<String, dynamic> json) => _Resonator(
  id: json['id'] as String,
  name: json['name'] as String,
  stars: (json['stars'] as num?)?.toInt() ?? 5,
  attribute: $enumDecode(_$AttributeEnumMap, json['attribute']),
  weapon: $enumDecode(_$WeaponEnumMap, json['weapon']),
  iconAsset: json['iconAsset'] as String,
  portraitAsset: json['portraitAsset'] as String,
  usableStats:
      (json['usableStats'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$StatEnumMap, e))
          .toList() ??
      const [],
  savedEchoSet: json['savedEchoSet'] == null
      ? null
      : EchoSet.fromJson(json['savedEchoSet'] as Map<String, dynamic>),
  teams:
      (json['teams'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  erImportance: json['erImportance'] as String?,
  damageSplit: (json['damageSplit'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  teamER: json['teamER'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ResonatorToJson(
  _Resonator instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'stars': instance.stars,
  'attribute': _$AttributeEnumMap[instance.attribute]!,
  'weapon': _$WeaponEnumMap[instance.weapon]!,
  'iconAsset': instance.iconAsset,
  'portraitAsset': instance.portraitAsset,
  'usableStats': instance.usableStats.map((e) => _$StatEnumMap[e]!).toList(),
  'savedEchoSet': ?instance.savedEchoSet,
  'teams': instance.teams,
  'erImportance': instance.erImportance,
  'damageSplit': instance.damageSplit,
  'teamER': instance.teamER,
};

const _$AttributeEnumMap = {
  Attribute.aero: 'aero',
  Attribute.electro: 'electro',
  Attribute.fusion: 'fusion',
  Attribute.glacio: 'glacio',
  Attribute.havoc: 'havoc',
  Attribute.spectro: 'spectro',
};

const _$WeaponEnumMap = {
  Weapon.broadblade: 'broadblade',
  Weapon.sword: 'sword',
  Weapon.pistols: 'pistols',
  Weapon.gauntlets: 'gauntlets',
  Weapon.rectifier: 'rectifier',
};

const _$StatEnumMap = {
  Stat.critRate: 'critRate',
  Stat.critDamage: 'critDamage',
  Stat.flatAtk: 'flatAtk',
  Stat.atkPercent: 'atkPercent',
  Stat.flatHp: 'flatHp',
  Stat.hpPercent: 'hpPercent',
  Stat.flatDef: 'flatDef',
  Stat.defPercent: 'defPercent',
  Stat.basicPercent: 'basicPercent',
  Stat.heavyPercent: 'heavyPercent',
  Stat.skillPercent: 'skillPercent',
  Stat.liberationPercent: 'liberationPercent',
  Stat.erPercent: 'erPercent',
};
