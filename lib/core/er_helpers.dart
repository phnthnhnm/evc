import '../domain/enums/stat.dart';

double extractERStat(Map<String, double> stats, int echoSlotNumber) {
  final key = '${Stat.erPercent.apiName} $echoSlotNumber';
  return stats[key] ?? 0.0;
}

double computeTotalERFromEchoes(List<Map<String, double>> echoStats) {
  double sum = 100.0;
  for (int i = 0; i < echoStats.length; i++) {
    sum += echoStats[i]['${Stat.erPercent.apiName} ${i + 1}'] ?? 0.0;
  }
  return (sum * 10).round() / 10.0;
}
