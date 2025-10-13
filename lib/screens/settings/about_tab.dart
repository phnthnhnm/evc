import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? snapshot.data!.version : '...';
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EVC GUI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Version: $version'),
              const SizedBox(height: 12),
              Text('Copyright © ${DateTime.now().year} Phan Thành Nam'),
              const SizedBox(height: 12),
              const Text('Author: Phan Thành Nam'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Source code: '),
                  InkWell(
                    child: const Text(
                      'github.com/phnthnhnm/evc',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      final url = Uri.parse('https://github.com/phnthnhnm/evc');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Relies on: '),
                  InkWell(
                    child: const Text(
                      'Echo Value Calculator by AstyuteChick',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      final url = Uri.parse('https://www.echovaluecalc.com');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                  const Text(' (licensed under GNU GPLv3)'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'This app uses assets from the game Wuthering Waves by Kuro Games. EVC GUI is not affiliated with or endorsed by Kuro Games. All trademarks and copyrights belong to their respective owners.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
