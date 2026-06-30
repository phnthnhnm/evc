import 'package:freezed_annotation/freezed_annotation.dart';

part 'echo.freezed.dart';
part 'echo.g.dart';

@freezed
abstract class Echo with _$Echo {
  const factory Echo({
    @Default({}) Map<String, double> stats,
    @Default(0.0) double score,
    @Default('Unbuilt') String tier,
  }) = _Echo;

  factory Echo.fromJson(Map<String, dynamic> json) => _$EchoFromJson(json);
}
