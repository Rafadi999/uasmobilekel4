class Announcement {
  final String? id;
  final String title;
  final String message;
  final DateTime date;

  Announcement({
    this.id,
    required this.title,
    required this.message,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
    };
  }

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}