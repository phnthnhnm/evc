// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'echo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Echo _$EchoFromJson(Map<String, dynamic> json) => _Echo(
  stats:
      (json['stats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  score: (json['score'] as num?)?.toDouble() ?? 0.0,
  tier: json['tier'] as String? ?? 'Unbuilt',
);

Map<String, dynamic> _$EchoToJson(_Echo instance) => <String, dynamic>{
  'stats': instance.stats,
  'score': instance.score,
  'tier': instance.tier,
};
