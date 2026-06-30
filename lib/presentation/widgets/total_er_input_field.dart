import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TotalERInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  final String label;
  final double width;
  final EdgeInsetsGeometry? padding;
  final Widget? infoContent;

  const TotalERInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.label = 'Total ER of the build:',
    this.width = 90,
    this.padding,
    this.infoContent,
  });

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Energy Regen'),
        content: infoContent!,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Text(label),
          if (infoContent != null) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 28,
              height: 28,
              child: InkWell(
                onTap: () => _showInfoPopup(context),
                borderRadius: BorderRadius.circular(14),
                child: const Icon(
                  Icons.help_outline,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
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
