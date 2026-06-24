import 'package:flutter/material.dart';

import 'total_er_input_field.dart';

class TeamRow extends StatelessWidget {
  final String selectedTeam;
  final List<String> teams;
  final ValueChanged<String> onTeamChanged;
  final TextEditingController erController;
  final ValueChanged<double> onERChanged;

  const TeamRow({
    super.key,
    required this.selectedTeam,
    required this.teams,
    required this.onTeamChanged,
    required this.erController,
    required this.onERChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Team:'),
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
        TotalERInputField(controller: erController, onChanged: onERChanged),
      ],
    );
  }
}
