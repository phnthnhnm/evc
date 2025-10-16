import 'package:flutter/material.dart';

class ResetResonatorButton extends StatelessWidget {
  final Future<void> Function(BuildContext context) onReset;
  final String label;
  final IconData icon;
  final Color? color;

  const ResetResonatorButton({
    Key? key,
    required this.onReset,
    this.label = 'Reset',
    this.icon = Icons.refresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Reset'),
            content: const Text(
              'Are you sure you want to reset this resonator? This will delete all its data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await onReset(context);
        }
      },
      icon: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      label: Text(label, style: TextStyle(color: color)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color != null ? color!.withOpacity(0.1) : null,
      ),
    );
  }
}
