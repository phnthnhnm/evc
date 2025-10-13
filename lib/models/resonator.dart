import '../data/stat.dart';
import 'echo.dart';

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
      return 'assets/attributes/aero.png';
    case Attribute.electro:
      return 'assets/attributes/electro.png';
    case Attribute.fusion:
      return 'assets/attributes/fusion.png';
    case Attribute.glacio:
      return 'assets/attributes/glacio.png';
    case Attribute.havoc:
      return 'assets/attributes/havoc.png';
    case Attribute.spectro:
      return 'assets/attributes/spectro.png';
  }
}

String weaponAsset(Weapon w) {
  switch (w) {
    case Weapon.broadblade:
      return 'assets/weapons/broadblade.png';
    case Weapon.sword:
      return 'assets/weapons/sword.png';
    case Weapon.pistols:
      return 'assets/weapons/pistols.png';
    case Weapon.gauntlets:
      return 'assets/weapons/gauntlets.png';
    case Weapon.rectifier:
      return 'assets/weapons/rectifier.png';
  }
}

String statAsset(Stat s) {
  switch (s) {
    case Stat.critRate:
      return 'assets/stats/cr.png';
    case Stat.critDamage:
      return 'assets/stats/cd.png';
    case Stat.flatAtk:
      return 'assets/stats/atk.png';
    case Stat.atkPercent:
      return 'assets/stats/atk.png';
    case Stat.flatHp:
      return 'assets/stats/hp.png';
    case Stat.hpPercent:
      return 'assets/stats/hp.png';
    case Stat.flatDef:
      return 'assets/stats/def.png';
    case Stat.defPercent:
      return 'assets/stats/def.png';
    case Stat.basicPercent:
      return 'assets/stats/basic.png';
    case Stat.heavyPercent:
      return 'assets/stats/heavy.png';
    case Stat.skillPercent:
      return 'assets/stats/skill.png';
    case Stat.liberationPercent:
      return 'assets/stats/liberation.png';
    case Stat.erPercent:
      return 'assets/stats/er.png';
  }
}

class Resonator {
  final String id;
  final String name;
  final Attribute attribute;
  final Weapon weapon;
  final String portraitAsset; // Optional: not used for rendering if null
  final List<Stat> usableStats;
  final EchoSet? savedEchoSet; // for autofill (optional cached)

  const Resonator({
    required this.id,
    required this.name,
    required this.attribute,
    required this.weapon,
    required this.portraitAsset,
    required this.usableStats,
    this.savedEchoSet,
  });

  Resonator copyWith({EchoSet? savedEchoSet}) {
    return Resonator(
      id: id,
      name: name,
      attribute: attribute,
      weapon: weapon,
      portraitAsset: portraitAsset,
      usableStats: usableStats,
      savedEchoSet: savedEchoSet ?? this.savedEchoSet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'attribute': attribute.index,
      'weapon': weapon.index,
      'portraitAsset': portraitAsset,
      'usableStats': usableStats,
      'savedEchoSet': savedEchoSet?.toJson(),
    };
  }

  static Resonator fromJson(Map<String, dynamic> json) {
    return Resonator(
      id: json['id'] as String,
      name: json['name'] as String,
      attribute: Attribute.values[json['attribute'] as int],
      weapon: Weapon.values[json['weapon'] as int],
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
