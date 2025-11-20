class Student {
  final String id;
  final String name;
  final String email;
  final String nis;
  final String kelas;
  final String jurusan;
  final String role;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.nis,
    required this.kelas,
    required this.jurusan,
    this.role = "siswa",
  });

  // Convert ke Map untuk simpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'nis': nis,
      'kelas': kelas,
      'jurusan': jurusan,
      'role': role,
    };
  }

  // Buat dari Firestore Map (hindari null error)
  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id,
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      nis: (map['nis'] ?? '').toString(),
      kelas: (map['kelas'] ?? '').toString(),
      jurusan: (map['jurusan'] ?? '').toString(),
      role: (map['role'] ?? 'siswa').toString(),
    );
  }
}