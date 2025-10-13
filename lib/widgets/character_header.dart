import 'package:flutter/material.dart';

import '../models/character.dart';

class CharacterHeader extends StatelessWidget {
  final Character character;
  const CharacterHeader({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final c = character;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.transparent,
          backgroundImage: c.portraitAsset.isNotEmpty
              ? AssetImage(c.portraitAsset)
              : null,
          child: c.portraitAsset.isEmpty
              ? Text(
                  c.name.isNotEmpty ? c.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Tooltip(
                    message: attributeLabel(c.attribute),
                    child: Image.asset(
                      attributeAsset(c.attribute),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: weaponLabel(c.weapon),
                    child: Image.asset(
                      weaponAsset(c.weapon),
                      width: 24,
                      height: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
