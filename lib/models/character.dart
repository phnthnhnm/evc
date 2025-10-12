import 'package:flutter/material.dart';

import 'echo.dart';

enum Weapon {
  broadblade,
  gauntlets,
  pistols,
  rectifier,
  sword,
}

enum Attribute {
  aero,
  electro,
  fusion,
  glacio,
  havoc,
  spectro,
}

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

IconData weaponIcon(Weapon w) {
  switch (w) {
    case Weapon.broadblade:
      return Icons.construction;
    case Weapon.gauntlets:
      return Icons.back_hand;
    case Weapon.pistols:
      return Icons.sports_handball;
    case Weapon.rectifier:
      return Icons.settings;
    case Weapon.sword:
      return Icons.gavel;
  }
}

IconData attributeIcon(Attribute a) {
  switch (a) {
    case Attribute.aero:
      return Icons.air;
    case Attribute.electro:
      return Icons.bolt;
    case Attribute.fusion:
      return Icons.local_fire_department;
    case Attribute.glacio:
      return Icons.ac_unit;
    case Attribute.havoc:
      return Icons.warning_amber_rounded;
    case Attribute.spectro:
      return Icons.blur_on;
  }
}

class Character {
  final String id;
  final String name;
  final Attribute attribute;
  final Weapon weapon;
  final String portraitUrl; // Optional: not used for rendering if null
  final List<String> usableStats;
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
      usableStats:
          (json['usableStats'] as List).map((e) => e.toString()).toList(),
      savedEchoSet: json['savedEchoSet'] != null
          ? EchoSet.fromJson(json['savedEchoSet'] as Map<String, dynamic>)
          : null,
    );
  }
}
