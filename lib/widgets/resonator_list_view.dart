import 'package:flutter/material.dart';

import '../models/echo.dart';
import '../models/resonator.dart';
import 'resonator_card.dart';

class ResonatorListView extends StatelessWidget {
  final List<Resonator> resonators;
  final Future<void> Function(Resonator, EchoSet?) onEchoSetSaved;
  final void Function(Resonator) onResonatorTap;

  const ResonatorListView({
    super.key,
    required this.resonators,
    required this.onEchoSetSaved,
    required this.onResonatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: resonators.map((resonator) {
            return SizedBox(
              width: 180,
              child: ResonatorCard(
                key: ValueKey(resonator.id),
                resonator: resonator,
                onTap: () => onResonatorTap(resonator),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
