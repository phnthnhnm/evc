import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TotalERInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  final String label;
  final double width;
  final EdgeInsetsGeometry? padding;

  const TotalERInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.label = 'Total ER of the build:',
    this.width = 90,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 12),
          SizedBox(
            width: width,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) {
                  onChanged(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
