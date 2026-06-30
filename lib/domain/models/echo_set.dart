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

List<Echo> _echoesFromJson(List<dynamic>? json) =>
    json?.map((e) => Echo.fromJson(e as Map<String, dynamic>)).toList() ??
    const [];

List<Map<String, dynamic>> _echoesToJson(List<Echo> echoes) =>
    echoes.map((e) => e.toJson()).toList();
