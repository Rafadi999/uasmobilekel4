  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../models/announcement.dart';
  import '../models/schedule.dart';

  class FirestoreService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // ================= 📖 GENERAL METHOD =================

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

    Stream<QuerySnapshot> getDataStream(String collection,
        {String? orderBy, bool descending = true}) {
      if (orderBy != null) {
        return _firestore
            .collection(collection)
            .orderBy(orderBy, descending: descending)
            .snapshots();
      }
      return _firestore.collection(collection).snapshots();
    }

    Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
        String collection, String docId) async {
      return await _firestore.collection(collection).doc(docId).get();
    }

    Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream(
        String collection, String docId) {
      return _firestore.collection(collection).doc(docId).snapshots();
    }

    // ================= 🔥 PENGUMUMAN =================

    Stream<List<Announcement>> getAnnouncements() {
      return _firestore
          .collection('pengumuman')
          .orderBy('dibuat', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Announcement.fromMap(doc.id, doc.data()))
              .toList());
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

    // ================= 📚 JADWAL =================
    // Tidak MERUBAH fungsi lain, hanya melengkapi jadwal

    /// 🔹 Ambil semua jadwal (Admin)
    Stream<List<Schedule>> getJadwalStream() {
      return _firestore
          .collection('jadwal')
          .orderBy('waktumulai')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Schedule.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ))
            .toList();
      });
    }

    /// 🔹 Ambil jadwal berdasarkan kelas (Siswa/Guru)
    Stream<List<Schedule>> getJadwalByClass(String className) {
      return _firestore
          .collection('jadwal')
          .where('namakelas', isEqualTo: className)
          .orderBy('waktumulai')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Schedule.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ))
            .toList();
      });
    }

    /// 🔹 Ambil jadwal berdasarkan ID Guru (Teacher)
    Stream<List<Schedule>> getJadwalByTeacher(String teacherId) {
      return _firestore
          .collection('jadwal')
          .where('idguru', isEqualTo: teacherId)
          .orderBy('waktumulai')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Schedule.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ))
            .toList();
      });
    }


    /// 🔹 Tambah jadwal
    Future<void> addJadwal(Schedule jadwal) async {
      await _firestore.collection('jadwal').add(jadwal.toMap());
    }

    /// 🔹 Update jadwal
    Future<void> updateJadwal(Schedule jadwal) async {
      await _firestore
          .collection('jadwal')
          .doc(jadwal.id)
          .update(jadwal.toMap());
    }

    /// 🔹 Hapus jadwal
    Future<void> deleteJadwal(String id) async {
      await _firestore.collection('jadwal').doc(id).delete();
    }
  }