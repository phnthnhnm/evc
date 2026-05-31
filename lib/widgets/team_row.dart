import 'package:flutter/material.dart';

import 'total_er_input_field.dart';

class TeamRow extends StatelessWidget {
  // Team selector row. `teams` is the list
  // of available team labels for this resonator. If empty, dropdown is disabled.
  final String? selectedTeam;
  final List<String> teams;
  final ValueChanged<String?> onTeamChanged;
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
        teams.isEmpty
            ? DropdownButton<String>(
                value: null,
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('No teams defined'),
                  ),
                ],
                onChanged: null,
              )
            : DropdownButton<String>(
                value: selectedTeam,
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...teams.map(
                    (t) => DropdownMenuItem(value: t, child: Text(t)),
                  ),
                ],
                onChanged: onTeamChanged,
              ),
        const Spacer(),
        TotalERInputField(controller: erController, onChanged: onERChanged),
      ],
    );
  }
}
