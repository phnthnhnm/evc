import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../data.dart';
import '../models/echo.dart';

class ApiService {
  static const String endpoint = 'https://www.echovaluecalc.com/full';

  // Build request map according to spec:
  // buff_full, char_full, er_tot_full, and for each stat and echo index 1..5 => value
  static Map<String, String> buildPayload({
    required String energyBuff, // None, Yangyang, Zhezhi
    required String characterName, // e.g., Carlotta
    required int totalER,
    required List<Map<String, double>> echoStatsList, // length 5
  }) {
    final map = <String, String>{};
    map['buff_full'] = energyBuff == 'None' ? 'None' : energyBuff;
    map['char_full'] = characterName;
    map['er_tot_full'] = totalER.toString();

    // All possible stat keys must be present, but stats not shown/unused should be 0.0.
    // We'll ensure all keys for indices 1..5 exist, default 0.0 if not provided.
    final statNames = allStats;

    for (int i = 0; i < 5; i++) {
      for (final stat in statNames) {
        final apiKey = '${statApiNames[stat]} ${i + 1}';
        final value = echoStatsList.length > i
            ? (echoStatsList[i][apiKey] ?? 0.0)
            : 0.0;
        map[apiKey] = value.toString();
      }
    }
    return map;
  }

  static Future<EchoSet> submit({
    required String energyBuff,
    required String characterName,
    required int totalER,
    required List<Map<String, double>> echoStatsList,
  }) async {
    final payload = buildPayload(
      energyBuff: energyBuff,
      characterName: characterName,
      totalER: totalER,
      echoStatsList: echoStatsList,
    );

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: payload.map((k, v) => MapEntry(k, Uri.encodeQueryComponent(v))),
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    // Parse HTML and extract sub_anal_f div content
    final document = html_parser.parse(response.body);
    final subAnal = document.querySelector('div.sub_anal_f');
    if (subAnal == null) {
      throw Exception('No result section found.');
    }

    // Expect two H2s:
    // 1) "overallScore: [e1, e2, e3, e4, e5]"
    // 2) "overallTier: ['tier1', ..., 'tier5']" with HTML entities for quotes
    final h2s = subAnal.querySelectorAll('div > h2');
    if (h2s.length < 2) {
      throw Exception('Incomplete result format.');
    }

    // Extract scores line
    final scoresText = h2s[0].text.trim();
    // Extract tiers line
    final tiersText = h2s[1].text.trim();

    // Example scoresText: "0.0: [0.0, 0.0, 0.0, 0.0, 0.0]"
    // Example tiersText: "Unbuilt: ['Unbuilt', 'Unbuilt', 'Unbuilt', 'Unbuilt', 'Unbuilt']"
    double overallScore = 0.0;
    final echoScores = <double>[0, 0, 0, 0, 0];
    String overallTier = 'Unbuilt';
    final echoTiers = <String>[
      'Unbuilt',
      'Unbuilt',
      'Unbuilt',
      'Unbuilt',
      'Unbuilt',
    ];

    try {
      final colonIdx = scoresText.indexOf(':');
      final overallStr = colonIdx >= 0
          ? scoresText.substring(0, colonIdx).trim()
          : scoresText;
      overallScore = double.tryParse(overallStr) ?? 0.0;

      final bracketStart = scoresText.indexOf('[');
      final bracketEnd = scoresText.indexOf(']');
      if (bracketStart >= 0 && bracketEnd > bracketStart) {
        final inner = scoresText.substring(bracketStart + 1, bracketEnd);
        final parts = inner.split(',').map((e) => e.trim()).toList();
        for (int i = 0; i < parts.length && i < 5; i++) {
          echoScores[i] = double.tryParse(parts[i]) ?? 0.0;
        }
      }

      final tierColonIdx = tiersText.indexOf(':');
      overallTier = tierColonIdx >= 0
          ? tiersText.substring(0, tierColonIdx).trim()
          : tiersText;

      final tBracketStart = tiersText.indexOf('[');
      final tBracketEnd = tiersText.lastIndexOf(']');
      if (tBracketStart >= 0 && tBracketEnd > tBracketStart) {
        var inner = tiersText.substring(tBracketStart + 1, tBracketEnd);
        // Remove quotes and HTML entities
        inner = inner.replaceAll('&#39;', '').replaceAll("'", '');
        final parts = inner.split(',').map((e) => e.trim()).toList();
        for (int i = 0; i < parts.length && i < 5; i++) {
          echoTiers[i] = parts[i];
        }
      }
    } catch (_) {
      // If parsing fails, keep defaults
    }

    final echoes = List<Echo>.generate(5, (i) {
      return Echo(
        stats: echoStatsList[i],
        score: echoScores[i],
        tier: echoTiers[i],
      );
    });

    return EchoSet(
      echoes: echoes,
      overallScore: overallScore,
      overallTier: overallTier,
      energyBuff: energyBuff,
      totalER: totalER,
    );
  }
}
