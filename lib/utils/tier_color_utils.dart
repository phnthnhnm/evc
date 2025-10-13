import 'package:flutter/material.dart';

Color getTierColor(String tier) {
  switch (tier) {
    case 'Godly':
    case 'Extreme':
      return Colors.amber;
    case 'High Investment':
    case 'Well Built':
      return Colors.purple;
    case 'Decent':
    case 'Base level':
      return Colors.blue;
    case 'Unbuilt':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
