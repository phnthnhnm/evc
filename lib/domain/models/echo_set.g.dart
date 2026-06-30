// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'echo_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EchoSet _$EchoSetFromJson(Map<String, dynamic> json) => _EchoSet(
  echoes: json['echoes'] == null
      ? const []
      : _echoesFromJson(json['echoes'] as List?),
  overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
  overallTier: json['overallTier'] as String? ?? 'Unbuilt',
  totalER: (json['totalER'] as num?)?.toDouble() ?? 100.0,
  team: json['team'] as String?,
);

Map<String, dynamic> _$EchoSetToJson(_EchoSet instance) => <String, dynamic>{
  'echoes': _echoesToJson(instance.echoes),
  'overallScore': instance.overallScore,
  'overallTier': instance.overallTier,
  'totalER': instance.totalER,
  'team': instance.team,
};
