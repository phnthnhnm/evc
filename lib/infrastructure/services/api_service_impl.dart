import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../core/interfaces/api_service.dart';
import '../../core/result.dart';
import '../../domain/enums/stat.dart';
import '../../domain/models/echo.dart';
import '../../domain/models/echo_set.dart';

final class ApiServiceImpl implements IApiService {
  static const String endpoint = 'https://www.echovaluecalc.com/calcFull';

  static const List<Stat> _ssrOrder = [
    Stat.critRate,
    Stat.critDamage,
    Stat.atkPercent,
    Stat.flatAtk,
    Stat.hpPercent,
    Stat.flatHp,
    Stat.defPercent,
    Stat.flatDef,
    Stat.basicPercent,
    Stat.heavyPercent,
    Stat.skillPercent,
    Stat.liberationPercent,
    Stat.erPercent,
  ];

  static const int _echoCount = 5;

  const ApiServiceImpl({this.client});
  final http.Client? client;

  http.Client get _client => client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Builder helpers
  // ---------------------------------------------------------------------------

  static List<List<double>> _buildSsrMatrix(
    List<Map<String, double>> echoStatsList,
  ) {
    final ssr = List.generate(
      _echoCount,
      (_) => List.filled(_ssrOrder.length, 0.0),
    );
    for (int i = 0; i < _echoCount; i++) {
      for (int j = 0; j < _ssrOrder.length; j++) {
        final stat = _ssrOrder[j];
        final baseName = stat.apiName;
        final key = '$baseName ${i + 1}';
        final value = (echoStatsList.length > i)
            ? (echoStatsList[i][key] ?? 0.0)
            : 0.0;
        ssr[i][j] = value;
      }
    }
    return ssr;
  }

  static Map<String, dynamic> _parseScoreString(
    String? scoreStr, {
    int count = _echoCount,
  }) {
    double overallScore = 0.0;
    final echoScores = List<double>.filled(count, 0.0);
    if (scoreStr == null) {
      return {'overallScore': overallScore, 'echoScores': echoScores};
    }
    final scoresText = scoreStr.trim();
    final colonIdx = scoresText.indexOf(':');
    overallScore = colonIdx >= 0
        ? double.tryParse(scoresText.substring(0, colonIdx).trim()) ?? 0.0
        : double.tryParse(scoresText) ?? 0.0;

    final bracketStart = scoresText.indexOf('[');
    final bracketEnd = scoresText.indexOf(']');
    if (bracketStart >= 0 && bracketEnd > bracketStart) {
      final inner = scoresText.substring(bracketStart + 1, bracketEnd);
      final parts = inner.split(',').map((e) => e.trim()).toList();
      for (int i = 0; i < parts.length && i < count; i++) {
        echoScores[i] = double.tryParse(parts[i]) ?? 0.0;
      }
    }
    return {'overallScore': overallScore, 'echoScores': echoScores};
  }

  static Map<String, dynamic> _parseTierString(
    String? tierStr, {
    int count = _echoCount,
  }) {
    String overallTier = 'Unbuilt';
    final echoTiers = List<String>.filled(count, 'Unbuilt');
    if (tierStr == null) {
      return {'overallTier': overallTier, 'echoTiers': echoTiers};
    }
    final tiersText = tierStr.trim();
    final tierColonIdx = tiersText.indexOf(':');
    overallTier = tierColonIdx >= 0
        ? tiersText.substring(0, tierColonIdx).trim()
        : tiersText;

    final tBracketStart = tiersText.indexOf('[');
    final tBracketEnd = tiersText.lastIndexOf(']');
    if (tBracketStart >= 0 && tBracketEnd > tBracketStart) {
      var inner = tiersText.substring(tBracketStart + 1, tBracketEnd);
      inner = inner.replaceAll('&#39;', '').replaceAll("'", '');
      final parts = inner.split(',').map((e) => e.trim()).toList();
      for (int i = 0; i < parts.length && i < count; i++) {
        echoTiers[i] = parts[i];
      }
    }
    return {'overallTier': overallTier, 'echoTiers': echoTiers};
  }

  static List<Echo> _buildEchoesFromSsr(
    List? ssr,
    List<Map<String, double>> echoStatsList,
    List<double> echoScores,
    List<String> echoTiers,
  ) {
    final echoes = <Echo>[];
    if (ssr != null) {
      for (int i = 0; i < _echoCount; i++) {
        final stats = <String, double>{};
        final row = i < ssr.length ? ssr[i] as List? : null;
        if (row != null) {
          for (int j = 0; j < row.length && j < _ssrOrder.length; j++) {
            final raw = row[j];
            double? val;
            if (raw is String) {
              val = double.tryParse(raw);
            } else if (raw is num) {
              val = raw.toDouble();
            }
            if (val != null && val != 0.0) {
              final statName = _ssrOrder[j].apiName;
              stats['$statName ${i + 1}'] = val;
            }
          }
        }
        echoes.add(
          Echo(stats: stats, score: echoScores[i], tier: echoTiers[i]),
        );
      }
    } else {
      for (int i = 0; i < _echoCount; i++) {
        final stats = (echoStatsList.length > i)
            ? Map<String, double>.from(echoStatsList[i])
            : <String, double>{};
        echoes.add(
          Echo(stats: stats, score: echoScores[i], tier: echoTiers[i]),
        );
      }
    }
    return echoes;
  }

  // ---------------------------------------------------------------------------
  // IApiService
  // ---------------------------------------------------------------------------

  @override
  Map<String, dynamic> buildPayload({
    required String resonatorName,
    required double totalER,
    required List<Map<String, double>> echoStatsList,
    String? team,
  }) {
    final ssr = _buildSsrMatrix(echoStatsList);
    final payload = <String, dynamic>{
      'char': resonatorName,
      'ssr': ssr,
      'totEr': totalER,
    };
    if (team != null) payload['team'] = team;
    return payload;
  }

  @override
  Future<Result<EchoSet>> submit({
    required String resonatorName,
    required double totalER,
    required List<Map<String, double>> echoStatsList,
    String? team,
  }) async {
    final payload = buildPayload(
      resonatorName: resonatorName,
      totalER: totalER,
      echoStatsList: echoStatsList,
      team: team,
    );

    final headers = {'Content-Type': 'application/json'};
    final jsonBody = jsonEncode(payload);

    if (kDebugMode) {
      debugPrint('[ApiService] --- HTTP Request ---');
      debugPrint('[ApiService] URL: $endpoint');
      debugPrint('[ApiService] JSON body: $jsonBody');
    }

    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonBody,
        encoding: Encoding.getByName('utf-8'),
      );

      if (kDebugMode) {
        debugPrint('[ApiService] Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        final snippet = response.body.length > 1000
            ? '${response.body.substring(0, 1000)}... (truncated)'
            : response.body;
        return Err(
          'Server error: ${response.statusCode}\nResponse body: $snippet',
        );
      }

      return _parseResponse(response.body, totalER, echoStatsList, team);
    } catch (e) {
      return Err('Network or parsing error', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Response parsing
  // ---------------------------------------------------------------------------

  Result<EchoSet> _parseResponse(
    String body,
    double totalER,
    List<Map<String, double>> echoStatsList,
    String? team,
  ) {
    // Try JSON first
    try {
      final Map<String, dynamic> jsonResp = jsonDecode(body);
      final teamResp = jsonResp['team'] as String?;
      final totalErResp =
          ((jsonResp['totEr']) as num?)?.toDouble() ?? totalER;
      final teamOut = teamResp ?? team;

      final ssr = jsonResp['ssr'] as List?;

      final parsedScore = _parseScoreString(jsonResp['score'] as String?);
      final parsedTier = _parseTierString(jsonResp['tier'] as String?);

      final echoScores = parsedScore['echoScores'] as List<double>;
      final echoTiers = parsedTier['echoTiers'] as List<String>;

      final double overallScore = jsonResp.containsKey('overallScore')
          ? (jsonResp['overallScore'] as num?)?.toDouble() ?? 0.0
          : parsedScore['overallScore'] as double;

      final String overallTier = jsonResp.containsKey('overallTier')
          ? jsonResp['overallTier'] as String? ?? 'Unbuilt'
          : parsedTier['overallTier'] as String;

      final echoes = _buildEchoesFromSsr(
        ssr,
        echoStatsList,
        echoScores,
        echoTiers,
      );

      return Ok(
        EchoSet(
          echoes: echoes,
          overallScore: overallScore,
          overallTier: overallTier,
          totalER: totalErResp,
          team: teamOut,
        ),
      );
    } catch (_) {
      // Fall through to HTML parsing
    }

    // Try HTML parsing
    try {
      final document = html_parser.parse(body);
      final subAnal = document.querySelector('div.sub_anal_f');
      if (subAnal == null) {
        return const Err('No result section found.');
      }

      final h2s = subAnal.querySelectorAll('div > h2');
      if (h2s.length < 2) {
        return const Err('Incomplete result format.');
      }

      final scoresText = h2s[0].text.trim();
      final tiersText = h2s[1].text.trim();

      final parsedScore = _parseScoreString(scoresText);
      final parsedTier = _parseTierString(tiersText);

      final double overallScore = parsedScore['overallScore'] as double;
      final List<double> echoScores =
          parsedScore['echoScores'] as List<double>;
      final String overallTier = parsedTier['overallTier'] as String;
      final List<String> echoTiers =
          parsedTier['echoTiers'] as List<String>;

      final echoes = List<Echo>.generate(_echoCount, (i) {
        final stats = (echoStatsList.length > i)
            ? Map<String, double>.from(echoStatsList[i])
            : <String, double>{};
        return Echo(
          stats: stats,
          score: echoScores[i],
          tier: echoTiers[i],
        );
      });

      return Ok(
        EchoSet(
          echoes: echoes,
          overallScore: overallScore,
          overallTier: overallTier,
          totalER: totalER,
          team: team,
        ),
      );
    } catch (e) {
      return Err('Failed to parse response', cause: e);
    }
  }
}
