import 'package:flutter/material.dart';

import '../models/character.dart';

class WeaponChoiceChips extends StatelessWidget {
  final Weapon? selected;
  final ValueChanged<Weapon?> onChanged;
  const WeaponChoiceChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weapons = Weapon.values;
    return Wrap(
      spacing: 8,
      children: [
        for (final weapon in weapons)
          ChoiceChip(
            label: Tooltip(
              message: weaponLabel(weapon),
              child: Image.asset(
                weaponAsset(weapon),
                width: 24,
                height: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            selected: selected == weapon,
            onSelected: (selectedChip) =>
                onChanged(selectedChip && selected != weapon ? weapon : null),
          ),
      ],
    );
  }
}
