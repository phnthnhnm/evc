import 'package:flutter/material.dart';

import '../models/resonator.dart';

class ResonatorHeader extends StatelessWidget {
  final Resonator resonator;
  const ResonatorHeader({super.key, required this.resonator});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.transparent,
          backgroundImage: resonator.iconAsset.isNotEmpty
              ? AssetImage(resonator.iconAsset)
              : null,
          child: resonator.iconAsset.isEmpty
              ? Text(
                  resonator.name.isNotEmpty ? resonator.name[0] : '?',
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
                resonator.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Tooltip(
                    message: attributeLabel(resonator.attribute),
                    child: Image.asset(
                      attributeAsset(resonator.attribute),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: weaponLabel(resonator.weapon),
                    child: Image.asset(
                      weaponAsset(resonator.weapon),
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
