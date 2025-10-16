import 'package:flutter/material.dart';

import '../utils/confirm_dialog.dart';

class ResetResonatorButton extends StatefulWidget {
  final Future<void> Function() onReset;
  final String label;
  final IconData icon;
  final Color? color;

  const ResetResonatorButton({
    super.key,
    required this.onReset,
    this.label = 'Reset',
    this.icon = Icons.refresh,
    this.color,
  });

  @override
  State<ResetResonatorButton> createState() => _ResetResonatorButtonState();
}

class _ResetResonatorButtonState extends State<ResetResonatorButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Confirm Reset',
          content:
              'Are you sure you want to reset this resonator\'s echo set? This will delete all their data.',
          confirmText: 'Reset',
          confirmColor: Colors.red,
        );
        if (confirmed) {
          await widget.onReset();
        }
      },
      icon: Icon(
        widget.icon,
        color: widget.color ?? Theme.of(context).colorScheme.primary,
      ),
      label: Text(widget.label, style: TextStyle(color: widget.color)),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color?.withAlpha((0.1 * 255).toInt()),
      ),
    );
  }
}
