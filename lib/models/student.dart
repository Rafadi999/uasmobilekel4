class Student {
  final String id;
  final String nis;
  final String name;
  final String kelas;
  final String jurusan;

  Student({required this.id, required this.nis, required this.name, required this.kelas, required this.jurusan});

  Map<String, dynamic> toMap() => {
    'nis': nis, 'name': name, 'kelas': kelas, 'jurusan': jurusan
  };

  factory Student.fromMap(String id, Map<String, dynamic> m) => Student(
    id: id, nis: m['nis'] ?? '', name: m['name'] ?? '', kelas: m['kelas'] ?? '', jurusan: m['jurusan'] ?? ''
  );
}