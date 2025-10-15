import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        const Text('Total ER of the build:'),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: TextFormField(
            controller: erController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            inputFormatters: [
              // Only allow numbers and '.'
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (v) {
              final parsed = double.tryParse(v);
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
