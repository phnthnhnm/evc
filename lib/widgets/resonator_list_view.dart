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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 28,
          runSpacing: 32,
          children: resonators.map((resonator) {
            return SizedBox(
              width: 240,
              height: 400,
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
