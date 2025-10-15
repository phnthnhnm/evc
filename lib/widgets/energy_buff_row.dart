import 'package:flutter/material.dart';

import 'total_er_input_field.dart';

class EnergyBuffRow extends StatelessWidget {
  final String energyBuff;
  final ValueChanged<String?> onBuffChanged;
  final TextEditingController erController;
  final ValueChanged<double> onERChanged;
  const EnergyBuffRow({
    super.key,
    required this.energyBuff,
    required this.onBuffChanged,
    required this.erController,
    required this.onERChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Energy buffs from outros:'),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: energyBuff,
          items: const [
            DropdownMenuItem(value: 'None', child: Text('None')),
            DropdownMenuItem(value: 'Yangyang', child: Text('Yangyang')),
            DropdownMenuItem(value: 'Zhezhi', child: Text('Zhezhi')),
          ],
          onChanged: onBuffChanged,
        ),
        const Spacer(),
        TotalERInputField(controller: erController, onChanged: onERChanged),
      ],
    );
  }
}
