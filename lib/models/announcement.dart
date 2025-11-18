class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  Announcement({required this.id, required this.title, required this.body, required this.createdAt});

  Map<String,dynamic> toMap() => {'title': title,'body': body,'createdAt': createdAt.toIso8601String()};

  factory Announcement.fromMap(String id, Map<String,dynamic> m) => Announcement(
    id: id,
    title: m['title'] ?? '',
    body: m['body'] ?? '',
    createdAt: DateTime.parse(m['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}