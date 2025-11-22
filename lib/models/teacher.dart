class Teacher {
  final String id;
  final String nama;
  final String email;
  final String nip;
  final String mapel;
  final String role;

  Teacher({
    required this.id,
    required this.nama,
    required this.email,
    required this.nip,
    required this.mapel,
    this.role = "guru",
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'nip': nip,
      'mapel': mapel,
      'role': role,
    };
  }

  factory Teacher.fromMap(String id, Map<String, dynamic> map) {
    return Teacher(
      id: id,
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      nip: map['nip'] ?? '',
      mapel: map['mapel'] ?? '',
      role: map['role'] ?? 'guru',
    );
  }
}