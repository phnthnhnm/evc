import 'package:flutter/material.dart';

class EnergyBuffRow extends StatelessWidget {
  final String energyBuff;
  final ValueChanged<String?> onBuffChanged;
  final int totalER;
  final ValueChanged<int> onERChanged;
  const EnergyBuffRow({
    super.key,
    required this.energyBuff,
    required this.onBuffChanged,
    required this.totalER,
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
        const Text('Total ER of the build:'),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: TextFormField(
            initialValue: totalER.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) {
                onERChanged(parsed);
              }
            },
          ),
        ),
      ],
    );
  }
}
