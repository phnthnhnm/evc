import 'package:flutter/material.dart';

import '../models/character.dart';

class AttributeFilterChips extends StatelessWidget {
  final Attribute? selected;
  final ValueChanged<Attribute?> onChanged;
  const AttributeFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final attributes = Attribute.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final attr in attributes)
          FilterChip(
            label: Tooltip(
              message: attributeLabel(attr),
              child: Image.asset(attributeAsset(attr), width: 24, height: 24),
            ),
            selected: selected == attr,
            onSelected: (selectedChip) =>
                onChanged(selectedChip && selected != attr ? attr : null),
          ),
      ],
    );
  }
}
