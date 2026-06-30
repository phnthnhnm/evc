import 'package:flutter/material.dart';

import '../../domain/enums/weapon_attribute.dart';

/// Centralized color utilities for the app.
abstract final class AppColors {
  /// Returns the color for a given echo tier string.
  static Color tierColor(String tier) => switch (tier) {
        'Godly' || 'Extreme' => Colors.amber,
        'High Investment' || 'Well Built' => Colors.purple,
        'Decent' || 'Base level' => Colors.blue,
        'Unbuilt' => Colors.green,
        _ => Colors.grey,
      };

  /// Returns the gold/purple color for resonator stars.
  static Color starColor(int stars) => switch (stars) {
        5 => const Color(0xFFFFD700),
        4 => const Color(0xFFB266FF),
        _ => Colors.grey.shade700,
      };

  /// Returns the background color for an attribute icon circle.
  static Color attributeBackground(Attribute attr) => switch (attr) {
        Attribute.aero => const Color(0xFF0D3027),
        Attribute.electro => const Color(0xFF2C1C3E),
        Attribute.glacio => const Color(0xFF0B2F37),
        Attribute.fusion => const Color(0xFF3A191B),
        Attribute.havoc => const Color(0xFF39192C),
        Attribute.spectro => const Color(0xFF2D260E),
      };
}
