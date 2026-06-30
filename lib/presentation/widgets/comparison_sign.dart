import 'package:flutter/material.dart';

class ComparisonSign extends StatelessWidget {
  final String sign;
  final double fontSize;
  final FontWeight fontWeight;

  const ComparisonSign({
    super.key,
    required this.sign,
    this.fontSize = 64,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        sign,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
    );
  }
}
