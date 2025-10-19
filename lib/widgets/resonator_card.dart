import 'package:flutter/material.dart';

import '../models/resonator.dart';

class ResonatorCard extends StatelessWidget {
  final Resonator resonator;
  final VoidCallback onTap;

  const ResonatorCard({
    super.key,
    required this.resonator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    return Card(
      elevation: 2,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage(resonator.iconAsset),
              ),
              const SizedBox(height: 12),
              Text(
                resonator.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
