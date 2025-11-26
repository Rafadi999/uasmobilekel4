class Student {
  final String id;
  final String nama;
  final String email;
  final String nis;
  final String kelas;
  final String jurusan;
  final String role;

  Student({
    required this.id,
    required this.nama,
    required this.email,
    required this.nis,
    required this.kelas,
    required this.jurusan,
    this.role = "siswa",
  });

  // Convert ke Map untuk simpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'nis': nis,
      'kelas': kelas,
      'jurusan': jurusan,
      'role': role,
    };
  }

  // Buat dari Firestore Map (hindari null error)
  factory Student.fromMap(String id, Map<String, dynamic> data) {
  return Student(
    id: id,
    nis: data['nis'] ?? '',
    nama: data['nama'] ?? '',
    kelas: data['kelas'] ?? '',
    email: data['email'] ?? '',
    jurusan: data['jurusan'] ?? '',
  );
}
}