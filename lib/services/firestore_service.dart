import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  // 🔹 Tambah data (Siswa/Guru/Jadwal)
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  // 🔹 Update data
  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // 🔹 Hapus data
  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // 🔹 Baca data stream (untuk realtime UI)
  Stream<QuerySnapshot> getDataStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}