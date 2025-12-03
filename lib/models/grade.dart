class Grade {
  final String id;
  final String siswaId;
  final String mapel;
  final double tugas;
  final double uts;
  final double uas;

  Grade({
    required this.id,
    required this.siswaId,
    required this.mapel,
    required this.tugas,
    required this.uts,
    required this.uas,
  });

  double get finalScore => tugas * 0.3 + uts * 0.3 + uas * 0.4;

  String get predicate {
    final n = finalScore;
    if (n >= 85) return "A";
    if (n >= 75) return "B";
    if (n >= 65) return "C";
    return "D";
  }

  Map<String, dynamic> toMap() => {
        "siswaId": siswaId,
        "mapel": mapel,  // <- FIX
        "tugas": tugas,
        "uts": uts,
        "uas": uas,
      };

  factory Grade.fromMap(String id, Map<String, dynamic> m) => Grade(
        id: id,
        siswaId: m["siswaId"] ?? "",
        mapel: m["mapel"] ?? "",   // <- FIX
        tugas: (m["tugas"] ?? 0).toDouble(),
        uts: (m["uts"] ?? 0).toDouble(),
        uas: (m["uas"] ?? 0).toDouble(),
      );
}
