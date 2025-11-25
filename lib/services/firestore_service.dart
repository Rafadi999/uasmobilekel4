import 'package:cloud_firestore/cloud_firestore.dart';
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