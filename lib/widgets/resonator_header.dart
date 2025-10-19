import 'package:flutter/material.dart';

import '../models/resonator.dart';
import '../utils/resonator_utils.dart';

class ResonatorHeader extends StatelessWidget {
  final Resonator resonator;
  const ResonatorHeader({super.key, required this.resonator});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.transparent,
          backgroundImage: resonator.iconAsset.isNotEmpty
              ? AssetImage(resonator.iconAsset)
              : null,
          child: resonator.iconAsset.isEmpty
              ? Text(
                  resonator.name.isNotEmpty ? resonator.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 32,
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
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getAttributeBackgroundColor(
                          resonator.attribute,
                        ).withValues(alpha: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        attributeAsset(resonator.attribute),
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: weaponLabel(resonator.weapon),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3A3F44).withValues(alpha: 0.7),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        weaponAsset(resonator.weapon),
                        width: 28,
                        height: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
