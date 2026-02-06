class SeanceStats {
  final String nomSeance;
  final double present;
  final double absent;

  SeanceStats({
    required this.nomSeance,
    required this.present,
    required this.absent,
  });
factory SeanceStats.fromJson(Map<String, dynamic> json) {
  return SeanceStats(
    nomSeance: json['nomSeance'] ?? 'Inconnu',
    present: (json['present'] is num) ? json['present'].toDouble() : 0.0,
    absent: (json['absent'] is num) ? json['absent'].toDouble() : 0.0,
  );
}
}