import 'package:flutter/material.dart';

class StatDropdown extends StatelessWidget {
  final Widget label;
  final List<double> values;
  final double selected;
  final ValueChanged<double> onChanged;

  const StatDropdown({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 140,
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w500),
            child: label,
          ),
        ),
        SizedBox(
          width: 80,
          child: DropdownButton<double>(
            value: selected,
            isExpanded: true,
            items: [
              const DropdownMenuItem<double>(value: 0.0, child: Text('0.0')),
              ...values.map(
                (v) => DropdownMenuItem<double>(
                  value: v,
                  child: Text(v.toString()),
                ),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
