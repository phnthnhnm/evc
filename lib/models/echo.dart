class Echo {
  // Selected stats and their numeric values
  final Map<String, double> stats; // e.g., { "Crit Rate(%) 1": 8.1 }
  final double score;
  final String tier;

  const Echo({
    required this.stats,
    required this.score,
    required this.tier,
  });

  Echo copyWith({Map<String, double>? stats, double? score, String? tier}) {
    return Echo(
      stats: stats ?? this.stats,
      score: score ?? this.score,
      tier: tier ?? this.tier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats,
      'score': score,
      'tier': tier,
    };
  }

  static Echo fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'] as Map<String, dynamic>? ?? {};
    final stats = statsRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    return Echo(
      stats: stats,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      tier: json['tier'] as String? ?? 'Unbuilt',
    );
  }
}

class EchoSet {
  final List<Echo> echoes; // 0..4 indexes represent Echo 1..5
  final double overallScore;
  final String overallTier;
  final String energyBuff; // None, Yangyang, Zhezhi
  final int totalER; // e.g., 100

  const EchoSet({
    required this.echoes,
    required this.overallScore,
    required this.overallTier,
    required this.energyBuff,
    required this.totalER,
  });

  EchoSet copyWith({
    List<Echo>? echoes,
    double? overallScore,
    String? overallTier,
    String? energyBuff,
    int? totalER,
  }) {
    return EchoSet(
      echoes: echoes ?? this.echoes,
      overallScore: overallScore ?? this.overallScore,
      overallTier: overallTier ?? this.overallTier,
      energyBuff: energyBuff ?? this.energyBuff,
      totalER: totalER ?? this.totalER,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'echoes': echoes.map((e) => e.toJson()).toList(),
      'overallScore': overallScore,
      'overallTier': overallTier,
      'energyBuff': energyBuff,
      'totalER': totalER,
    };
  }

  static EchoSet fromJson(Map<String, dynamic> json) {
    final echoes = (json['echoes'] as List? ?? [])
        .map((e) => Echo.fromJson(e as Map<String, dynamic>))
        .toList();
    return EchoSet(
      echoes: echoes,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      overallTier: json['overallTier'] as String? ?? 'Unbuilt',
      energyBuff: json['energyBuff'] as String? ?? 'None',
      totalER: json['totalER'] as int? ?? 100,
    );
  }
}
