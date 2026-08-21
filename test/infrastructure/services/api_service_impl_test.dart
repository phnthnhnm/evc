import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:evc/core/result.dart';
import 'package:evc/domain/models/echo_set.dart';
import 'package:evc/infrastructure/services/api_service_impl.dart';

void main() {
  group('ApiServiceImpl.submit', () {
    test('returns Err when API responds 200 with an Unexpected Error payload',
        () async {
      final service = ApiServiceImpl(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'score': 'Unexpected Error - Team not found',
              'tier': 'Error',
            }),
            200,
          );
        }),
      );

      final result = await service.submit(
        resonatorName: 'Ciaccona',
        totalER: 120.8,
        echoStatsList: List.generate(5, (_) => <String, double>{}),
        team: 'Low-Reqs',
      );

      expect(result, isA<Err<EchoSet>>());
      expect((result as Err<EchoSet>).message, contains('Team not found'));
    });

    test('returns Ok with parsed score and tier for a valid response',
        () async {
      final service = ApiServiceImpl(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'score':
                  '75.831: [64.949, 95.847, 65.488, 80.909, 71.962]',
              'tier': "Well Built: ['Decent', 'Extreme', 'Decent', "
                  "'High Investment', 'Well Built']",
            }),
            200,
          );
        }),
      );

      final result = await service.submit(
        resonatorName: 'Ciaccona',
        totalER: 120.8,
        echoStatsList: List.generate(5, (_) => <String, double>{}),
        team: 'Default',
      );

      final echoSet = (result as Ok<EchoSet>).value;
      expect(echoSet.overallScore, 75.831);
      expect(echoSet.overallTier, 'Well Built');
      expect(echoSet.echoes, hasLength(5));
    });

    test('sends the team name verbatim in the payload', () async {
      late Map<String, dynamic> sentBody;
      final service = ApiServiceImpl(
        client: MockClient((request) async {
          sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'score': '1: [1, 1, 1, 1, 1]', 'tier': 'Unbuilt'}),
            200,
          );
        }),
      );

      await service.submit(
        resonatorName: 'Ciaccona',
        totalER: 120.8,
        echoStatsList: List.generate(5, (_) => <String, double>{}),
        team: 'Low-Reqs: ',
      );

      expect(sentBody['team'], 'Low-Reqs: ');
      expect(sentBody['char'], 'Ciaccona');
      expect(sentBody['totEr'], 120.8);
    });
  });
}
