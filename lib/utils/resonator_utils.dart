import 'package:flutter/material.dart';

import '../models/resonator.dart';

Color getStarColor(int stars) {
  if (stars == 5) return const Color(0xFFFFD700);
  if (stars == 4) return const Color(0xFFB266FF);
  return Colors.grey.shade700;
}

Color getAttributeBackgroundColor(Attribute attribute) {
  switch (attribute) {
    case Attribute.aero:
      return const Color(0xFF0d3027);
    case Attribute.electro:
      return const Color(0xFF2c1c3e);
    case Attribute.glacio:
      return const Color(0xFF0b2f37);
    case Attribute.fusion:
      return const Color(0xFF3a191b);
    case Attribute.havoc:
      return const Color(0xFF39192c);
    case Attribute.spectro:
      return const Color(0xFF2d260e);
  }
}
