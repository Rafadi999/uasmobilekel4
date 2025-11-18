enum UserRole { admin, teacher, student }

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;

  AppUser({required this.uid, required this.email, required this.name, required this.role});

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'role': role.toString().split('.').last,
  };

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
    uid: uid,
    email: m['email'] ?? '',
    name: m['name'] ?? '',
    role: (m['role'] == 'admin') ? UserRole.admin : (m['role'] == 'teacher') ? UserRole.teacher : UserRole.student,
  );
}