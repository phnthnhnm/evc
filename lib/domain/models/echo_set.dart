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

  /// Parses JSON that may contain legacy keys (`totEr` → `totalER`,
  /// `energyBuff` → `team`) and normalizes them before deserializing.
  factory EchoSet.fromLegacyJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json);

    if (!data.containsKey('totalER') && data.containsKey('totEr')) {
      data['totalER'] = data['totEr'];
    }

    if (!data.containsKey('team') && data.containsKey('energyBuff')) {
      data['team'] = data['energyBuff'];
    }

    return EchoSet.fromJson(data);
  }
}

List<Echo> _echoesFromJson(List<dynamic>? json) =>
    json?.map((e) => Echo.fromJson(e as Map<String, dynamic>)).toList() ??
    const [];

List<Map<String, dynamic>> _echoesToJson(List<Echo> echoes) =>
    echoes.map((e) => e.toJson()).toList();
