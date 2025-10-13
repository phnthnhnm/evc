import '../data.dart';
import 'echo.dart';

enum Weapon { broadblade, gauntlets, pistols, rectifier, sword }

enum Attribute { aero, electro, fusion, glacio, havoc, spectro }

String weaponLabel(Weapon w) {
  switch (w) {
    case Weapon.broadblade:
      return 'Broadblade';
    case Weapon.gauntlets:
      return 'Gauntlets';
    case Weapon.pistols:
      return 'Pistols';
    case Weapon.rectifier:
      return 'Rectifier';
    case Weapon.sword:
      return 'Sword';
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
      return 'assets/weapons/broadblade.webp';
    case Weapon.gauntlets:
      return 'assets/weapons/gauntlet.webp';
    case Weapon.pistols:
      return 'assets/weapons/pistol.webp';
    case Weapon.rectifier:
      return 'assets/weapons/rectifier.webp';
    case Weapon.sword:
      return 'assets/weapons/sword.webp';
  }
}

class Character {
  final String id;
  final String name;
  final Attribute attribute;
  final Weapon weapon;
  final String portraitUrl; // Optional: not used for rendering if null
  final List<Stat> usableStats;
  final EchoSet? savedEchoSet; // for autofill (optional cached)

  const Character({
    required this.id,
    required this.name,
    required this.attribute,
    required this.weapon,
    required this.portraitUrl,
    required this.usableStats,
    this.savedEchoSet,
  });

  Character copyWith({EchoSet? savedEchoSet}) {
    return Character(
      id: id,
      name: name,
      attribute: attribute,
      weapon: weapon,
      portraitUrl: portraitUrl,
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
      'portraitUrl': portraitUrl,
      'usableStats': usableStats,
      'savedEchoSet': savedEchoSet?.toJson(),
    };
  }

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      attribute: Attribute.values[json['attribute'] as int],
      weapon: Weapon.values[json['weapon'] as int],
      portraitUrl: json['portraitUrl'] as String? ?? '',
      usableStats: (json['usableStats'] as List)
          .map(
            (e) => statLabels.entries
                .firstWhere(
                  (entry) => entry.value == e,
                  orElse: () => MapEntry(Stat.critRate, 'Crit Rate(%)'),
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
