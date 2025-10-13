import 'package:flutter/material.dart';

class EnergyBuffRow extends StatefulWidget {
  final String energyBuff;
  final ValueChanged<String?> onBuffChanged;
  final double totalER;
  final ValueChanged<double> onERChanged;
  const EnergyBuffRow({
    super.key,
    required this.energyBuff,
    required this.onBuffChanged,
    required this.totalER,
    required this.onERChanged,
  });

  @override
  State<EnergyBuffRow> createState() => _EnergyBuffRowState();
}

class _EnergyBuffRowState extends State<EnergyBuffRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.totalER.toString());
  }

  @override
  void didUpdateWidget(EnergyBuffRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalER != widget.totalER &&
        _controller.text != widget.totalER.toString()) {
      _controller.text = widget.totalER.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Energy buffs from outros:'),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: widget.energyBuff,
          items: const [
            DropdownMenuItem(value: 'None', child: Text('None')),
            DropdownMenuItem(value: 'Yangyang', child: Text('Yangyang')),
            DropdownMenuItem(value: 'Zhezhi', child: Text('Zhezhi')),
          ],
          onChanged: widget.onBuffChanged,
        ),
        const Spacer(),
        const Text('Total ER of the build:'),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) {
                widget.onERChanged(parsed);
              }
            },
          ),
        ),
      ],
    );
  }
}
