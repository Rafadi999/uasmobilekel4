import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/schedule.dart';
import '../models/announcement.dart';
import '../models/grade.dart';
import '../models/nilai.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================
  // STUDENTS (USERS ROLE SISWA)
  // ==========================
  Stream<List<Student>> getStudentsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'siswa')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Student.fromMap(d.id, d.data())).toList());
  }

  // ==========================
  // TEACHERS (USERS ROLE GURU)
  // ==========================
  Stream<List<Teacher>> getTeachersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'guru')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Teacher.fromMap(d.id, d.data())).toList());
  }

  // ==========================
  //  ANNOUNCEMENT
  // ==========================
  Stream<List<Announcement>> getAnnouncements() {
    return _db.collection('pengumuman').snapshots().map(
          (snap) =>
              snap.docs.map((d) => Announcement.fromMap(d.id, d.data())).toList(),
        );
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

  // ==========================
  //  JADWAL
  // ==========================
  Stream<List<Schedule>> getJadwalStream() {
    return _db.collection('jadwal').snapshots().map(
          (snap) =>
              snap.docs.map((d) => Schedule.fromMap(d.id, d.data())).toList(),
        );
  }

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

  // ==========================
  // NILAI (ASLI)
  // ==========================
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
=======
import '../models/announcement.dart';
import '../models/schedule.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 📌 GENERAL FIREBASE HELPERS
  // ============================================================

  Future<String> addData(String collection, Map<String, dynamic> data) async {
    DocumentReference docRef = await _firestore.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> setData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream(
      String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // ============================================================
  // 📢 PENGUMUMAN
  // ============================================================

  Stream<List<Announcement>> getAnnouncements() {
    return _firestore
        .collection('pengumuman')
        .orderBy('dibuat', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Announcement.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _firestore.collection('pengumuman').add(announcement.toMap());
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _firestore
        .collection('pengumuman')
        .doc(announcement.id)
        .update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('pengumuman').doc(id).delete();
  }

  // ============================================================
  // 👥 USERS
  // ============================================================

  /// Ambil user berdasarkan email (login)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    QuerySnapshot query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.data() as Map<String, dynamic>;
  }

  /// Stream user berdasarkan UID
  Stream<Map<String, dynamic>?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      return doc.data() as Map<String, dynamic>?;
    });
  }

  /// Cek role user: siswa atau guru
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) return null;

    return userDoc.get('role');
  }

  // ============================================================
  // 📚 JADWAL PELAJARAN
  // ============================================================

  /// Admin: semua jadwal
  Stream<List<Schedule>> getJadwalStream() {
    return _firestore
        .collection('jadwal')
        .orderBy('waktumulai')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList());
  }

  /// Siswa: berdasarkan kelas
  Stream<List<Schedule>> getJadwalByClass(String className) {
    return _firestore
        .collection('jadwal')
        .where('kelas', isEqualTo: className) // ⚠ Pastikan field benar
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList());
  }

  /// Guru: berdasarkan UID guru
  Stream<List<Schedule>> getJadwalByTeacher(String teacherUid) {
    return _firestore
        .collection('jadwal')
        .where('idguru', isEqualTo: teacherUid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Schedule.fromDoc(doc)).toList());
  }

  Future<void> addJadwal(Schedule jadwal) async {
    await _firestore.collection('jadwal').add({
      ...jadwal.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateJadwal(Schedule jadwal) async {
    await _firestore.collection('jadwal').doc(jadwal.id).update({
      ...jadwal.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteJadwal(String id) async {
    await _firestore.collection('jadwal').doc(id).delete();
  }
}
>>>>>>> d96931a40b2aa92daa8bfb1f447f27d5d15e9a36
