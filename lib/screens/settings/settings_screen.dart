import 'package:flutter/material.dart';

import 'about_tab.dart';
import 'appearance_tab.dart';
import 'data_tab.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Appearance', icon: Icon(Icons.palette)),
              Tab(text: 'Data', icon: Icon(Icons.save)),
              Tab(text: 'About', icon: Icon(Icons.info)),
            ],
          ),
        ),
        body: TabBarView(
          children: [const AppearanceTab(), DataTab(), const AboutTab()],
        ),
      ),
    );
  }
}
