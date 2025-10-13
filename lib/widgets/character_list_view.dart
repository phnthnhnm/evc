import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/echo.dart';
import '../screens/character_detail_screen.dart';
import '../widgets/character_card.dart';
// ...existing code...

class CharacterListView extends StatelessWidget {
  final List<Character> characters;
  final Future<void> Function(Character, EchoSet?) onEchoSetSaved;
  const CharacterListView({
    super.key,
    required this.characters,
    required this.onEchoSetSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: characters.map((character) {
            return SizedBox(
              width: 180,
              child: CharacterCard(
                character: character,
                onTap: () async {
                  final result = await Navigator.push<EchoSet?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CharacterDetailScreen(character: character),
                    ),
                  );
                  await onEchoSetSaved(character, result);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
