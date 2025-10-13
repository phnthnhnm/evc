import 'package:flutter/material.dart';

import '../models/echo.dart';
import '../models/resonator.dart';
import '../screens/resonator_detail_screen.dart';
import 'resonator_card.dart';

class ResonatorListView extends StatelessWidget {
  final List<Resonator> resonators;
  final Future<void> Function(Resonator, EchoSet?) onEchoSetSaved;
  const ResonatorListView({
    super.key,
    required this.resonators,
    required this.onEchoSetSaved,
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
                resonator: resonator,
                onTap: () async {
                  final result = await Navigator.push<EchoSet?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResonatorDetailScreen(resonator: resonator),
                    ),
                  );
                  await onEchoSetSaved(resonator, result);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
