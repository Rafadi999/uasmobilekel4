class Teacher {
  final String id;
  final String nip;
  final String name;
  final String subject;

  Teacher({required this.id, required this.nip, required this.name, required this.subject});

  Map<String, dynamic> toMap() => {'nip': nip, 'name': name, 'subject': subject};

  factory Teacher.fromMap(String id, Map<String, dynamic> m) => Teacher(
    id: id, nip: m['nip'] ?? '', name: m['name'] ?? '', subject: m['subject'] ?? ''
  );
}