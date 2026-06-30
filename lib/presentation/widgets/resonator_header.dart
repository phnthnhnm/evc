import 'package:flutter/material.dart';

import 'package:evc/domain/enums/weapon_attribute.dart';
import 'package:evc/domain/models/resonator.dart';
import 'package:evc/presentation/theme/app_colors.dart';

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
                    message: resonator.attribute.label,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.attributeBackground(
                          resonator.attribute,
                        ).withValues(alpha: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        resonator.attribute.assetPath,
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: resonator.weapon.label,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3A3F44).withValues(alpha: 0.7),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        resonator.weapon.assetPath,
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
