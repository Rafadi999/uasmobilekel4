// lib/models/schedule.dart
class Schedule {
  final String id;
  final String className;
  final String subject;
  final String teacherName;
  final String day;
  final String startTime;
  final String endTime;

  Schedule({
    required this.id,
    required this.className,
    required this.subject,
    required this.teacherName,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'subject': subject,
      'teacherName': teacherName,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory Schedule.fromMap(String id, Map<String, dynamic> data) {
    return Schedule(
      id: id,
      className: (data['className'] ?? '').toString(),
      subject: (data['subject'] ?? '').toString(),
      teacherName: (data['teacherName'] ?? '').toString(),
      day: (data['day'] ?? '').toString(),
      startTime: (data['startTime'] ?? '').toString(),
      endTime: (data['endTime'] ?? '').toString(),
    );
  }
}