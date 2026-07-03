import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'total_er_input_field.dart';

class TeamRow extends StatelessWidget {
  final String selectedTeam;
  final List<String> teams;
  final ValueChanged<String> onTeamChanged;
  final TextEditingController erController;
  final ValueChanged<double> onERChanged;
  final bool showTeamInfo;
  final bool showERInfo;

  const TeamRow({
    super.key,
    required this.selectedTeam,
    required this.teams,
    required this.onTeamChanged,
    required this.erController,
    required this.onERChanged,
    this.showTeamInfo = false,
    this.showERInfo = false,
  });

  static const _boldStyle = TextStyle(fontWeight: FontWeight.bold);

  static const _linkStyle = TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );

  Widget _buildTeamInfoContent(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
        children: [
          const TextSpan(
            text:
                "If you don't see your team, or in case of doubt, please select the option with \"",
          ),
          const TextSpan(text: 'Default', style: _boldStyle),
          const TextSpan(text: '"!\n\n'),
          const TextSpan(text: 'This option sets the '),
          const TextSpan(text: 'widely accepted ER-target', style: _boldStyle),
          const TextSpan(
            text:
                ' for the character outside of the specific teams.\n\n'
                'For more details, check out ',
          ),
          TextSpan(
            text: 'Articles → Character Data',
            style: _linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse('https://www.echovaluecalc.com/cd');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  void _showTeamInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Team'),
        content: _buildTeamInfoContent(context),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildERInfoContent(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
        children: const [
          TextSpan(text: 'Make sure your character is "'),
          TextSpan(text: 'battle-ready', style: _boldStyle),
          TextSpan(
            text:
                '" (they have the correct weapon and echoes equipped) '
                'before entering this number.\n\n'
                'The weapon and echoes equipped should match the '
                "echo/build you're testing.\n\n",
          ),
          TextSpan(text: 'Beware: ', style: _boldStyle),
          TextSpan(
            text:
                'some regions in Lahai-Roi randomly give '
                'your characters additional ER, which may produce '
                'incorrect/unexpected results.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton(VoidCallback onTap) {
    return SizedBox(
      width: 28,
      height: 28,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Icon(Icons.help_outline, size: 20, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Team:'),
        if (showTeamInfo) ...[
          const SizedBox(width: 4),
          _buildHelpButton(() => _showTeamInfoPopup(context)),
        ],
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: selectedTeam,
          items: teams
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) {
            if (v != null) onTeamChanged(v);
          },
        ),
        const Spacer(),
        TotalERInputField(
          controller: erController,
          onChanged: onERChanged,
          infoContent: showERInfo ? _buildERInfoContent(context) : null,
        ),
      ],
    );
  }
}
