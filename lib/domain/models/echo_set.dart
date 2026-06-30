import 'package:freezed_annotation/freezed_annotation.dart';

import 'echo.dart';

part 'echo_set.freezed.dart';
part 'echo_set.g.dart';

@freezed
abstract class EchoSet with _$EchoSet {
  const factory EchoSet({
    @JsonKey(fromJson: _echoesFromJson, toJson: _echoesToJson)
    @Default([])
    List<Echo> echoes,
    @JsonKey(name: 'overallScore') @Default(0.0) double overallScore,
    @JsonKey(name: 'overallTier') @Default('Unbuilt') String overallTier,
    @JsonKey(name: 'totalER') @Default(100.0) double totalER,
    String? team,
  }) = _EchoSet;

  factory EchoSet.fromJson(Map<String, dynamic> json) =>
      _$EchoSetFromJson(json);
}

/// Pattern that matches the echo-slot suffix on stat keys (" 1" … " 5").
final _slotSuffix = RegExp(r' \d+$');

List<Echo> _echoesFromJson(List<dynamic>? json) {
  if (json == null) return const [];
  return json.asMap().entries.map((entry) {
    final i = entry.key;
    final map = Map<String, dynamic>.from(entry.value as Map<String, dynamic>);
    if (map['stats'] case final Map<String, dynamic> rawStats) {
      final suffixed = <String, double>{};
      rawStats.forEach((key, value) {
        // If the key already has a suffix (old format), replace it with the
        // correct one. Otherwise add the suffix based on array position.
        final base = key.replaceAll(_slotSuffix, '');
        suffixed['$base ${i + 1}'] = (value as num).toDouble();
      });
      map['stats'] = suffixed;
    }
    return Echo.fromJson(map);
  }).toList();
}

List<Map<String, dynamic>> _echoesToJson(List<Echo> echoes) =>
    echoes.map((echo) {
      final json = echo.toJson();
      // Strip the echo-slot suffix from stat keys before persisting.
      if (json['stats'] case final Map<String, dynamic> rawStats) {
        final clean = <String, double>{};
        rawStats.forEach((key, value) {
          clean[key.replaceAll(_slotSuffix, '')] = (value as num).toDouble();
        });
        json['stats'] = clean;
      }
      return json;
    }).toList();
