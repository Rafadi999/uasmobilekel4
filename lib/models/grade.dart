class Grade {
  final String id;
  final String studentId;
  final String subject;
  final double tugas;
  final double uts;
  final double uas;

  Grade({required this.id, required this.studentId, required this.subject, required this.tugas, required this.uts, required this.uas});

  double get finalScore => tugas * .3 + uts * .3 + uas * .4;
  String get predicate {
    final v = finalScore;
    if (v >= 85) return 'A';
    if (v >= 75) return 'B';
    if (v >= 65) return 'C';
    return 'D';
  }

  Map<String,dynamic> toMap() => {'studentId': studentId,'subject': subject,'tugas': tugas,'uts': uts,'uas': uas};

  factory Grade.fromMap(String id, Map<String,dynamic> m) => Grade(
    id: id,
    studentId: m['studentId'] ?? '',
    subject: m['subject'] ?? '',
    tugas: (m['tugas'] ?? 0).toDouble(),
    uts: (m['uts'] ?? 0).toDouble(),
    uas: (m['uas'] ?? 0).toDouble(),
  );
}