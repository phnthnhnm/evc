import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/theme_provider.dart';

class AppearanceTab extends StatelessWidget {
  const AppearanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Theme:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            RadioGroup<ThemeMode>(
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? mode) => themeProvider.setThemeMode(mode!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('System'),
                    leading: Radio<ThemeMode>(value: ThemeMode.system),
                  ),
                  ListTile(
                    title: const Text('Light'),
                    leading: Radio<ThemeMode>(value: ThemeMode.light),
                  ),
                  ListTile(
                    title: const Text('Dark'),
                    leading: Radio<ThemeMode>(value: ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
