import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/schedule.dart';
import '../models/announcement.dart';
import '../models/grade.dart';
import '../models/nilai.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // 👥 USERS
  // ============================================================

  // Mengambil data siswa dari collection "users"
// Hanya yang role = "siswa"
// Mengembalikan Stream<List<Student>> yang bisa langsung dipakai di StreamBuilder
Stream<List<Student>> getStudentsStream() {
  return _db
      .collection('users')
      .where('role', isEqualTo: 'siswa')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Student.fromMap(d.id, d.data())).toList());
}


  Stream<List<Teacher>> getTeachersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'guru')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Teacher.fromMap(d.id, d.data())).toList());
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final q = await _db
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return null;
    return doc.get("role");
  }

  // ============================================================
  // 📢 PENGUMUMAN
  // ============================================================

  Stream<List<Announcement>> getAnnouncements() {
    return _db
        .collection('pengumuman')
        .orderBy("dibuat", descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Announcement.fromMap(d.id, d.data())).toList());
  }

  Future<void> addAnnouncement(Announcement a) async {
    await _db.collection('pengumuman').add(a.toMap());
  }

  Future<void> updateAnnouncement(Announcement a) async {
    await _db.collection('pengumuman').doc(a.id).update(a.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('pengumuman').doc(id).delete();
  }

  // ============================================================
  // 📚 JADWAL
  // ============================================================

  Stream<List<Schedule>> getJadwalStream() {
    return _db.collection('jadwal').snapshots().map(
          (snap) =>
              snap.docs.map((d) => Schedule.fromMap(d.id, d.data())).toList(),
        );
  }

  // lib/services/firestore_service.dart
Stream<List<Schedule>> getJadwalByTeacher(String teacherId) {
  return _db
      .collection('jadwal')
      .where('idguru', isEqualTo: teacherId)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Schedule.fromMap(d.id, d.data())).toList());
}

  Stream<List<Schedule>> getJadwalByClass(String className) {
    return _db
        .collection('jadwal')
        .where('namakelas', isEqualTo: className)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Schedule.fromMap(d.id, d.data())).toList());
  }

  Future<void> addJadwal(Schedule s) async {
    await _db.collection('jadwal').add(s.toMap());
  }

  Future<void> updateJadwal(Schedule s) async {
    await _db.collection('jadwal').doc(s.id).update(s.toMap());
  }

  Future<void> deleteJadwal(String id) async {
    await _db.collection('jadwal').doc(id).delete();
  }

  // ============================================================
  // 📝 NILAI SISWA
  // ============================================================

  Stream<List<Nilai>> streamNilaiByStudent(String studentId) {
    return _db
        .collection("nilai")
        .where("idSiswa", isEqualTo: studentId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Nilai.fromMap(d.id, d.data())).toList());
  }

  Future<void> saveNilai(Nilai nilai) async {
    await _db.collection("nilai").add(nilai.toMap());
  }
}
