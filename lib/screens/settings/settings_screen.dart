import 'package:flutter/material.dart';

import 'about_tab.dart';
import 'appearance_tab.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Appearance', icon: Icon(Icons.palette)),
              Tab(text: 'About', icon: Icon(Icons.info)),
            ],
          ),
        ),
        body: const TabBarView(children: [AppearanceTab(), AboutTab()]),
      ),
    );
  }
}
