import '../data/stat.dart';
import 'echo.dart';

class Resonator {
  final String id;
  final String name;
  final int stars;
  final Attribute attribute;
  final Weapon weapon;
  final String iconAsset;
  final String portraitAsset;
  final List<Stat> usableStats;
  final EchoSet? savedEchoSet;

  const Resonator({
    required this.id,
    required this.name,
    required this.stars,
    required this.attribute,
    required this.weapon,
    required this.iconAsset,
    required this.portraitAsset,
    required this.usableStats,
    this.savedEchoSet,
  });

  Resonator copyWith({EchoSet? savedEchoSet}) {
    return Resonator(
      id: id,
      name: name,
      stars: stars,
      attribute: attribute,
      weapon: weapon,
      iconAsset: iconAsset,
      portraitAsset: portraitAsset,
      usableStats: usableStats,
      savedEchoSet: savedEchoSet ?? this.savedEchoSet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stars': stars,
      'attribute': attribute.index,
      'weapon': weapon.index,
      'iconAsset': iconAsset,
      'portraitAsset': portraitAsset,
      'usableStats': usableStats,
      'savedEchoSet': savedEchoSet?.toJson(),
    };
  }

  static Resonator fromJson(Map<String, dynamic> json) {
    return Resonator(
      id: json['id'] as String,
      name: json['name'] as String,
      stars: json['stars'] as int? ?? 5,
      attribute: Attribute.values[json['attribute'] as int],
      weapon: Weapon.values[json['weapon'] as int],
      iconAsset: json['iconAsset'] as String? ?? '',
      portraitAsset: json['portraitAsset'] as String? ?? '',
      usableStats: (json['usableStats'] as List)
          .map(
            (e) => statApiNames.entries
                .firstWhere(
                  (entry) => entry.value == e,
                  orElse: () => MapEntry(Stat.critRate, 'Crit. Rate'),
                )
                .key,
          )
          .toList(),
      savedEchoSet: json['savedEchoSet'] != null
          ? EchoSet.fromJson(json['savedEchoSet'] as Map<String, dynamic>)
          : null,
    );
  }
}

enum Weapon { broadblade, sword, pistols, gauntlets, rectifier }

enum Attribute { aero, electro, fusion, glacio, havoc, spectro }

String weaponLabel(Weapon w) {
  switch (w) {
    case Weapon.broadblade:
      return 'Broadblade';
    case Weapon.sword:
      return 'Sword';
    case Weapon.pistols:
      return 'Pistols';
    case Weapon.gauntlets:
      return 'Gauntlets';
    case Weapon.rectifier:
      return 'Rectifier';
  }
}

String attributeLabel(Attribute a) {
  switch (a) {
    case Attribute.aero:
      return 'Aero';
    case Attribute.electro:
      return 'Electro';
    case Attribute.fusion:
      return 'Fusion';
    case Attribute.glacio:
      return 'Glacio';
    case Attribute.havoc:
      return 'Havoc';
    case Attribute.spectro:
      return 'Spectro';
  }
}

String attributeAsset(Attribute a) {
  switch (a) {
    case Attribute.aero:
      return 'assets/attribute_icons/aero.png';
    case Attribute.electro:
      return 'assets/attribute_icons/electro.png';
    case Attribute.fusion:
      return 'assets/attribute_icons/fusion.png';
    case Attribute.glacio:
      return 'assets/attribute_icons/glacio.png';
    case Attribute.havoc:
      return 'assets/attribute_icons/havoc.png';
    case Attribute.spectro:
      return 'assets/attribute_icons/spectro.png';
  }
}

String weaponAsset(Weapon w) {
  switch (w) {
    case Weapon.broadblade:
      return 'assets/weapon_icons/broadblade.png';
    case Weapon.sword:
      return 'assets/weapon_icons/sword.png';
    case Weapon.pistols:
      return 'assets/weapon_icons/pistols.png';
    case Weapon.gauntlets:
      return 'assets/weapon_icons/gauntlets.png';
    case Weapon.rectifier:
      return 'assets/weapon_icons/rectifier.png';
  }
}

String statAsset(Stat s) {
  switch (s) {
    case Stat.critRate:
      return 'assets/stat_icons/cr.png';
    case Stat.critDamage:
      return 'assets/stat_icons/cd.png';
    case Stat.flatAtk:
      return 'assets/stat_icons/atk.png';
    case Stat.atkPercent:
      return 'assets/stat_icons/atk.png';
    case Stat.flatHp:
      return 'assets/stat_icons/hp.png';
    case Stat.hpPercent:
      return 'assets/stat_icons/hp.png';
    case Stat.flatDef:
      return 'assets/stat_icons/def.png';
    case Stat.defPercent:
      return 'assets/stat_icons/def.png';
    case Stat.basicPercent:
      return 'assets/stat_icons/basic.png';
    case Stat.heavyPercent:
      return 'assets/stat_icons/heavy.png';
    case Stat.skillPercent:
      return 'assets/stat_icons/skill.png';
    case Stat.liberationPercent:
      return 'assets/stat_icons/liberation.png';
    case Stat.erPercent:
      return 'assets/stat_icons/er.png';
  }
}
