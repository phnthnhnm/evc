enum Weapon { broadblade, sword, pistols, gauntlets, rectifier }

enum Attribute { aero, electro, fusion, glacio, havoc, spectro }

/// Human-readable label and asset path for a [Weapon].
extension WeaponX on Weapon {
  String get label => switch (this) {
    Weapon.broadblade => 'Broadblade',
    Weapon.sword => 'Sword',
    Weapon.pistols => 'Pistols',
    Weapon.gauntlets => 'Gauntlets',
    Weapon.rectifier => 'Rectifier',
  };

  String get assetPath => switch (this) {
    Weapon.broadblade => 'assets/weapon_icons/broadblade.webp',
    Weapon.sword => 'assets/weapon_icons/sword.webp',
    Weapon.pistols => 'assets/weapon_icons/pistols.webp',
    Weapon.gauntlets => 'assets/weapon_icons/gauntlets.webp',
    Weapon.rectifier => 'assets/weapon_icons/rectifier.webp',
  };
}

/// Human-readable label and asset path for an [Attribute].
extension AttributeX on Attribute {
  String get label => switch (this) {
    Attribute.aero => 'Aero',
    Attribute.electro => 'Electro',
    Attribute.fusion => 'Fusion',
    Attribute.glacio => 'Glacio',
    Attribute.havoc => 'Havoc',
    Attribute.spectro => 'Spectro',
  };

  String get assetPath => switch (this) {
    Attribute.aero => 'assets/attribute_icons/aero.webp',
    Attribute.electro => 'assets/attribute_icons/electro.webp',
    Attribute.fusion => 'assets/attribute_icons/fusion.webp',
    Attribute.glacio => 'assets/attribute_icons/glacio.webp',
    Attribute.havoc => 'assets/attribute_icons/havoc.webp',
    Attribute.spectro => 'assets/attribute_icons/spectro.webp',
  };
}
