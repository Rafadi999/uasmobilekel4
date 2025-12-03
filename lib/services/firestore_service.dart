// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/schedule.dart';
import '../models/announcement.dart';
import '../models/nilai.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // 👥 USERS (SISWA & GURU)
  // ============================================================

  // Stream Siswa
  Stream<List<Student>> getStudentsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'siswa')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Student.fromMap(d.id, d.data())).toList());
  }

  // Stream Guru
  Stream<List<Teacher>> getTeachersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'guru')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Teacher.fromMap(d.id, d.data())).toList());
  }

  // Helper: Get User by Email (untuk Login manual jika perlu)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final q = await _db
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  // Helper: Get Role
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
  // 📅 JADWAL (Mendukung Filter Guru & Siswa)
  // ============================================================
  
  Stream<List<Schedule>> getScheduleByRole({
    required String role,
    String? idGuru,
    String? idKelas,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('jadwal');

    // Filter berdasarkan Role
    if (role == 'guru' && idGuru != null) {
      query = query.where('idguru', isEqualTo: idGuru);
    } else if (role == 'siswa' && idKelas != null) {
      // NOTE: Pastikan di database fieldnya 'idkelas' (lowercase) atau sesuaikan
      query = query.where('idkelas', isEqualTo: idKelas);
    }
    // Jika role 'admin' atau 'all', tidak ada filter (ambil semua)

    // Sorting (Opsional)
    // NOTE: Query dengan 'where' dan 'orderBy' mungkin butuh Index di Firestore Console
    // Jika error "The query requires an index", buat index di link yang muncul di debug console.
    try {
      query = query.orderBy('createdAt', descending: true);
    } catch (e) {
      // Fallback jika field createdAt belum ada di dokumen lama
      print("Info: Sorting jadwal dilewati karena field createdAt kosong/error index");
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => Schedule.fromMap(d.id, d.data())).toList());
  }

  Future<void> addJadwal(Schedule s) async {
    // Gunakan .doc() kosong agar ID digenerate otomatis oleh Firestore
    final docRef = _db.collection('jadwal').doc(); 
    await docRef.set(s.toMap());
  }

  Future<void> updateJadwal(Schedule s) async {
    if (s.id.isEmpty) return;
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
        .where("siswaId", isEqualTo: studentId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Nilai.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Nilai>> streamSemuaNilai() {
    return _db.collection("nilai").snapshots().map((snap) =>
        snap.docs.map((d) => Nilai.fromMap(d.id, d.data())).toList());
  }

  Future<void> saveNilai(Nilai nilai) async {
    await _db.collection("nilai").add(nilai.toMap());
  }
}