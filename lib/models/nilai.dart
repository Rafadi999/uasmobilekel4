class Nilai {
  final String siswaId;
  final String mapel;
  final double tugas;
  final double uts;
  final double uas;
  final double nilaiAkhir;
  final String predikat;

  Nilai({
    required this.siswaId,
    required this.mapel,
    required this.tugas,
    required this.uts,
    required this.uas,
    required this.nilaiAkhir,
    required this.predikat,
  });

  Map<String, dynamic> toMap() {
    return {
      'siswaId': siswaId,
      'mapel': mapel,
      'tugas': tugas,
      'uts': uts,
      'uas': uas,
      'nilaiAkhir': nilaiAkhir,
      'predikat': predikat,
    };
  }

  factory Nilai.fromMap(String id, Map<String, dynamic> data) {
  return Nilai(
    siswaId: data['siswaId'],
    mapel: data['mapel'],
    tugas: (data['tugas'] ?? 0).toDouble(),
    uts: (data['uts'] ?? 0).toDouble(),
    uas: (data['uas'] ?? 0).toDouble(),
    nilaiAkhir: (data['nilaiAkhir'] ?? 0).toDouble(),
    predikat: data['predikat'] ?? "",
  );
}

}
