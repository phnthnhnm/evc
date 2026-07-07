import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TotalERInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onChanged;
  final String label;
  final double width;
  final EdgeInsetsGeometry? padding;
  final Widget? infoContent;

  /// When false, the field is disabled with a tooltip explanation.
  final bool enabled;

  /// ER target range for the selected team, or null if no data.
  final Map<String, double>? erTarget;

  /// The current ER value entered by the user.
  final double currentER;

  const TotalERInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.label = 'Total ER of the build:',
    this.width = 90,
    this.padding,
    this.infoContent,
    this.enabled = true,
    this.erTarget,
    this.currentER = 100.0,
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

  /// Computes feedback text and border color based on ER value vs target.
  ({String? feedbackText, Color? feedbackColor, Color? borderColor})
  _computeERFeedback() {
    if (!enabled || erTarget == null) {
      return (feedbackText: null, feedbackColor: null, borderColor: null);
    }
    final min = erTarget!['min']!;
    final max = erTarget!['max']!;
    final rangeStr = '${min.toStringAsFixed(1)} – ${max.toStringAsFixed(1)}';
    if (currentER < min) {
      return (
        feedbackText: 'Below optimal ($rangeStr)',
        feedbackColor: Colors.red,
        borderColor: Colors.red,
      );
    } else if (currentER > max) {
      return (
        feedbackText: 'Above optimal ($rangeStr)',
        feedbackColor: Colors.orange,
        borderColor: Colors.orange,
      );
    } else {
      return (
        feedbackText: '✓ Optimal ($rangeStr)',
        feedbackColor: Colors.green,
        borderColor: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedback = _computeERFeedback();

    final inputField = SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        enabled: enabled,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: feedback.borderColor != null
              ? OutlineInputBorder(
                  borderSide: BorderSide(color: feedback.borderColor!),
                )
              : null,
          focusedBorder: feedback.borderColor != null
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: feedback.borderColor!,
                    width: 2.0,
                  ),
                )
              : null,
          isDense: true,
        ),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onChanged: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
      ),
    );

    final disabledField = enabled
        ? inputField
        : Tooltip(
            message: 'ER is not required for this character in this team.',
            child: inputField,
          );

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              disabledField,
            ],
          ),
          if (feedback.feedbackText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                feedback.feedbackText!,
                style: TextStyle(
                  fontSize: 12,
                  color: feedback.feedbackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
